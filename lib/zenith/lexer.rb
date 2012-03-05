require 'rltk/lexer'

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

    rule(/[0-9]+/) { |t| [:INT, t.to_i] }
    rule(/[a-zA-Z*>.-]+/) { |t| [:IDENT, t] }

    # Ruby-style comments and whitespace are ignored.
    rule(/#.*/)
    rule(/\s/)
  end
end
