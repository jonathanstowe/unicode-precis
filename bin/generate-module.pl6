#!/usr/bin/env perl6

use v6.c;

#-------------------------------------------------------------------------------
# ftp://unicode.org/Public/3.2-Update/UnicodeData-3.2.0.html
# Field Name                            N/I Explanation
# 0     Code point                      N   Code point.
# 1     Character name                  N   These names match exactly the names published in the code charts of the Unicode Standard.
# 2     General Category                N   This is a useful breakdown into various "character types" which can be used as a default categorization in implementations. See below for a brief explanation.
# 3     Canonical Combining Classes     N   The classes used for the Canonical Ordering Algorithm in the Unicode Standard. These classes are also printed in Chapter 4 of the Unicode Standard.
# 4     Bidirectional Category          N   See the list below for an explanation of the abbreviations used in this field. These are the categories required by the Bidirectional Behavior Algorithm in the Unicode Standard. These categories are summarized in Chapter 3 of the Unicode Standard.
# 5     Character Decomposition Mapping N   In the Unicode Standard, not all of the mappings are full (maximal) decompositions. Recursive application of look-up for decompositions will, in all cases, lead to a maximal decomposition. The decomposition mappings match exactly the decomposition mappings published with the character names in the Unicode Standard.
# 6     Decimal digit value             N   This is a numeric field. If the character has the decimal digit property, as specified in Chapter 4 of the Unicode Standard, the value of that digit is represented with an integer value in this field
# 7     Digit value                     N   This is a numeric field. If the character represents a digit, not necessarily a decimal digit, the value is here. This covers digits which do not form decimal radix forms, such as the compatibility superscript digits
# 8     Numeric value                   N   This is a numeric field. If the character has the numeric property, as specified in Chapter 4 of the Unicode Standard, the value of that character is represented with an integer or rational number in this field. This includes fractions as, e.g., "1/5" for U+2155 VULGAR FRACTION ONE FIFTH Also included are numerical values for compatibility characters such as circled numbers.
# 9     Mirrored                        N   If the character has been identified as a "mirrored" character in bidirectional text, this field has the value "Y"; otherwise "N". The list of mirrored characters is also printed in Chapter 4 of the Unicode Standard.
# 10    Unicode 1.0 Name                I   This is the old name as published in Unicode 1.0. This name is only provided when it is significantly different from the current name for the character. The value of field 10 for control characters does not always match the Unicode 1.0 names. Instead, field 10 contains ISO 6429 names for control functions, for printing in the code charts.
# 11    10646 comment field             I   This is the ISO 10646 comment field. It appears in parentheses in the 10646 names list, or contains an asterisk to mark an Annex P note.
# 12    Uppercase Mapping               N   Upper case equivalent mapping. If a character is part of an alphabet with case distinctions, and has a simple upper case equivalent, then the upper case equivalent is in this field. See the explanation below on case distinctions. These mappings are always one-to-one, not one-to-many or many-to-one.
#                                           Note: This field is omitted if the uppercase is the same as field 0. For full case mappings, see UAX #21 Case Mappings and SpecialCasing.txt.
# 13 	Lowercase Mapping 	        N   Similar to Uppercase mapping
#                                           Note: This field is omitted if the lowercase is the same as field 0. For full case mappings, see UAX #21 Case Mappings and SpecialCasing.txt.
# 14 	Titlecase Mapping 	        N   Similar to Uppercase mapping.
#                                           Note: This field is omitted if the titlecase is the same as field 12. For full case mappings, see UAX #21 Case Mappings and SpecialCasing.txt.
#
my Map $ucd-names .= new(
  < codepoint character-name general-catagory
    canonical-combining-classes bidirectional-category
    character-decomposition-mapping decimal-digit-value
    digit-value numeric-value mirrored unicode10name
    iso10646-comment-field uppercase-mapping lowercase-mapping
    titlecase-mapping
  >.kv
);

#-------------------------------------------------------------------------------
#say "A: ", @*ARGS.perl;
multi sub MAIN ( 'UCD', Str :$class-name!, Str :$ucd-cat! ) {

say $ucd-cat;
  my Hash $h = ucd-db(:ucd-cat($ucd-cat.split(/\h* ',' \h*/)));
  generate-module( :class-name('PRECIS::Tables::' ~ $class-name), :ucd-db($h));
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  say Q:to/EO-USE/;

  Generate modules based on character tables from several sources.

  Usage:
    generate-module.pl6 --class-name=<Str> --ucd-cat=<List> UCD


  Options:
    --class-name        Name of the class generated. This will be a
                        generated as follows;

                          unit package Unicode;
                          module PRECIS::Tables::$class-name {
                            ...
                          }

                        The module is generated in the current directory as
                        $class-name.pm6. After generating the file, it can be
                        moved to other places.

    When UCD (Unicode Database)
    --ucd-cat           This is a list of comma separated strings. These
                        strings are searched in the UnicodeData.txt from
                        http://unicode.org/Public/9.0.0/ucd/UnicodeData.txt.
                        This file must be found in the current directory


  EO-USE
}

#-------------------------------------------------------------------------------
sub ucd-db ( List :$ucd-cat --> Hash ) {

  my Str $unicode-data-file = '<UnicodeData.txt';
  my Hash $unicode-data = {};
  my Bool $first-of-range-found = False;
  my Str $codepoint-start;
  for $unicode-data-file.IO.lines -> $line {

    my Array $unicode-data-entry = [$line.split(';')];
    my Str $catagory = $unicode-data-entry[2];

    if $unicode-data-entry[2] ~~ any(@$ucd-cat) {
      if !$first-of-range-found and $unicode-data-entry[1] ~~ m/ 'First>' / {
        $first-of-range-found = True;
        $codepoint-start = $unicode-data-entry[0];
      }

      elsif $first-of-range-found and $unicode-data-entry[1] ~~ m/ 'Last>' / {
        $first-of-range-found = False;

        my Str $entry = "0x$codepoint-start..0x$unicode-data-entry[0]";
        for ^ $ucd-names.elems -> $ui {
          $unicode-data{$entry}{$ucd-names{$ui}} =
            $unicode-data-entry[$ui] if ? $unicode-data-entry[$ui];
        }

        $unicode-data{$entry}<codepoint> = $entry;
      }

      else {
        my Str $entry = "0x$unicode-data-entry[0]";
        for ^ $ucd-names.elems -> $ui {
#say "$ui: $unicode-data-entry[$ui]" if ? $unicode-data-entry[$ui];
          $unicode-data{$entry}{$ucd-names{$ui}} =
            $unicode-data-entry[$ui] if ? $unicode-data-entry[$ui];
        }

        $unicode-data{$entry}<codepoint> = $entry;
      }
    }
  }

  $unicode-data;
};

#-------------------------------------------------------------------------------
sub generate-module (
  Str :$class-name, Hash :$ucd-db,
  Bool :$gen-table = False, Bool :$gen-set = True
  --> Nil
  ) {

  my $class-text = Qs:q:to/HEADER/;
    use v6.c;
    unit package Unicode;

    module $class-name {

    HEADER

  if $gen-table {
    $class-text ~= '    our $table = %(' ~ "\n    ";
    for $ucd-db.keys.sort -> $codepoint {

    }

    $class-text ~= "  );\n";
  }

  elsif $gen-set {
    $class-text ~= '  our $set = Set.new: (' ~ "\n    ";
    my $cnt = 1;
    for $ucd-db.keys.sort -> $cp {
      $class-text ~= "$cp, ";
      $class-text ~= "\n    " unless $cnt++ % 8;
    }

    $class-text ~= "\n  ).flat;\n";
  }

  $class-text ~= "};\n";

say "\n$class-text";
  my Str $fn = $class-name;
  $fn ~~ s:g/ [ <-[:]>+ '::' ] //;

  spurt( "$fn.pm6", $class-text);
}