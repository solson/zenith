require 'rltk/lexer'
require 'stringio'

module Zenith
  class Lexer < RLTK::Lexer
    rule(/module/) { :MODULE }
    rule(/use/) { :USE }
    rule(/fn/) { :FN }
    rule(/:/) { :COLON }
    rule(/;/) { :SEMICOLON }

    rule(/\(/) { set_flag(:stack_effect); :LPAREN }
    rule(/\)/, :default, [:stack_effect]) { unset_flag(:stack_effect); :RPAREN }
    rule(/->/, :default, [:stack_effect]) { :RARROW }

    rule(/\[/) { :LBRACKET }
    rule(/\]/) { :RBRACKET }

    rule(/{/) { :LBRACE }
    rule(/}/) { :RBRACE }

    rule(/'(?:\\'|[^'])*'/) do |t|
      char = parse_string_escapes(t[1..-2])
      raise "More than one character in character literal" if char.length > 1
      [:CHAR, char]
    end
    rule(/"(?:\\"|[^"])*"/) { |t| [:STRING, parse_string_escapes(t[1..-2])] }

    # TODO: number and identifier parsing
    rule(/[0-9]+/) { |t| [:INT, t.to_i] }
    rule(/[a-zA-Z*>.-]+/) { |t| [:IDENT, t] }

    # Ruby-style comments and whitespace are ignored.
    rule(/#.*/)
    rule(/\s/)

    class Environment < Environment
      def parse_string_escapes(source, delimiter='"')
        ret = ""
        sio = StringIO.new(source)
        ret << parse_char_escape(sio, delimiter) while !sio.eof?
        ret
      end

      def parse_char_escape(sio, delimiter='\'')
        ret = ""
        while c = sio.read(1)
          ret << if c == '\\'
            raise "Char escape ended in backslash" unless c2 = sio.read(1)
            case c2
            when 'a' then "\a"
            when 'b' then "\b"
            when 't' then "\t"
            when 'n' then "\n"
            when 'v' then "\v"
            when 'f' then "\f"
            when 'r' then "\r"
            when 'e' then "\e"
            when 'x' then parse_char_hex_escape(sio)
            else c2
            end
          else
            c
          end
        end
        ret
      end

      # Takes an IO (usually StringIO) argument
      def parse_char_hex_escape(sio)
        hex = sio.read(2)
        raise "Hex char escape ended prematurely" unless hex && hex.length == 2
        raise "Invalid hex escape: \\x#{hex}" unless hex =~ /^[a-zA-Z0-9]{2}$/
        hex.to_i(16).chr
      end
    end
  end
end
