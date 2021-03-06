use v6.c;
use Test;

use Unicode::PRECIS;
use Unicode::PRECIS::Tables;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;
use Unicode::PRECIS::Identifier::UsernameCasePreserved;

#-------------------------------------------------------------------------------
subtest {
  test-match( 0x00C0, 'Lu');
  test-match( 0x00e9, 'Ll');

  ok 0x5FFFE (elem) $Unicode::PRECIS::Tables::NonCharCodepoint::set,
     '0x5FFFE in NonCharCodepoint set';

  ok 0xFDD0 (elem) $Unicode::PRECIS::Tables::NonCharCodepoint::set,
     '0x5FFFE in NonCharCodepoint set';

  ok 0x0064 (elem) $ascii7, '0x0064 in Ascii7 set';

  is $exceptions{0x00DF}, 'PVALID', 'exceptions check for PVALID';
  is $exceptions{0x0660}, 'CONTEXTO', 'exceptions check for CONTEXTO';

}, 'Test tables';

#-------------------------------------------------------------------------------
subtest {

  my Unicode::PRECIS $p .= new;

  my Int $codepoint = 0x05DD;
  ok $p.letter-digits($codepoint),
     "$codepoint.fmt('0x%06x') in letter-digits set";

  $codepoint = 0x05C6;
  nok $p.letter-digits($codepoint),
     "$codepoint.fmt('0x%06x') not in letter-digits set";

  $codepoint = 0x0660;
  ok $p.exceptions($codepoint) ~~ 'CONTEXTO',
     "$codepoint.fmt('0x%06x') is a $p.exceptions($codepoint) exception";

  $codepoint = 0x00DF;
  ok $p.exceptions($codepoint) ~~ 'PVALID',
     "$codepoint.fmt('0x%06x') is a $p.exceptions($codepoint) exception";

  $codepoint = 0x10FEEE;
  ok $p.exceptions($codepoint) ~~ 'NOT-IN-SET',
     "$codepoint.fmt('0x%06x') is a $p.exceptions($codepoint) exception";

  $codepoint = 0x100E;
  ok $p.backward-compatible($codepoint) ~~ 'NOT-IN-SET',
     "$codepoint.fmt('0x%06x') is a $p.backward-compatible($codepoint) backwards compatible";

  $codepoint = 0x00DF;
  nok $p.join-control($codepoint),
     "$codepoint.fmt('0x%06x') is not a join control";

  $codepoint = 0x200C;
  ok $p.join-control($codepoint),
     "$codepoint.fmt('0x%06x') is a join control";

  $codepoint = 0x11A7;
  ok $p.old-hangul-jamo($codepoint),
     "$codepoint.fmt('0x%06x') in old-hangul-jamo set";

  $codepoint = 0x01A7;
  nok $p.old-hangul-jamo($codepoint),
     "$codepoint.fmt('0x%06x') not in old-hangul-jamo set";

  $codepoint = 0xFDDA;
  ok $p.unassigned($codepoint),
     "$codepoint.fmt('0x%06x') in unassigned set";

  $codepoint = 0xFDC0;
  nok $p.unassigned($codepoint),
     "$codepoint.fmt('0x%06x') not in unassigned set";

  $codepoint = 0x0024;
  ok $p.ascii7($codepoint),
     "$codepoint.fmt('0x%06x') in ascii 7 set";

  $codepoint = 0xF143;
  nok $p.ascii7($codepoint),
     "$codepoint.fmt('0x%06x') not in ascii 7 set";

  $codepoint = 0x008A;
  ok $p.control($codepoint),
     "$codepoint.fmt('0x%06x') in control set";

  $codepoint = 0xF140;
  nok $p.control($codepoint),
     "$codepoint.fmt('0x%06x') not in control set";

  $codepoint = 0x00AD;
  ok $p.precis-ignorable-properties($codepoint),
     "$codepoint.fmt('0x%06x') in ignorable set";

  $codepoint = 0x5FFFE;
  ok $p.precis-ignorable-properties($codepoint),
     "$codepoint.fmt('0x%06x') in ignorable set";

  $codepoint = 0xFFFC;
  nok $p.precis-ignorable-properties($codepoint),
     "$codepoint.fmt('0x%06x') not in ignorable set";

  $codepoint = 0x00A0;
  ok $p.space($codepoint),
     "$codepoint.fmt('0x%06x') in spaces set";

  $codepoint = 0x00A1;
  nok $p.space($codepoint),
     "$codepoint.fmt('0x%06x') not in spaces set";

  $codepoint = 0x02C2;
  ok $p.symbol($codepoint),
     "$codepoint.fmt('0x%06x') in symbol set";

  $codepoint = 0x02DC;
  ok $p.symbol($codepoint),
     "$codepoint.fmt('0x%06x') in symbol set";

  $codepoint = 0x037E;
  nok $p.symbol($codepoint),
     "$codepoint.fmt('0x%06x') not in symbol set";

  $codepoint = 0x037E;
  ok $p.punctuation($codepoint),
     "$codepoint.fmt('0x%06x') in punctuation set";

  $codepoint = 0x0F3B;
  ok $p.punctuation($codepoint),
     "$codepoint.fmt('0x%06x') in punctuation set";

  $codepoint = 0x0F3E;
  nok $p.punctuation($codepoint),
     "$codepoint.fmt('0x%06x') not in punctuation set";

  $codepoint = 0x1e9a;
  ok $p.has-compat($codepoint),
     "$codepoint.fmt('0x%06x') in has-compat set";

  $codepoint = 0x006a;
  nok $p.has-compat($codepoint),
     "$codepoint.fmt('0x%06x') not in has-compat set";

  $codepoint = 0x1F88;
  ok $p.other-letter-digits($codepoint),
     "$codepoint.fmt('0x%06x') in other-letter-digits set";

  $codepoint = 0x2070;
  ok $p.other-letter-digits($codepoint),
     "$codepoint.fmt('0x%06x') in other-letter-digits set";

  $codepoint = 0xD800;
  nok $p.other-letter-digits($codepoint),
     "$codepoint.fmt('0x%06x') not in other-letter-digits set";

}, "Test PRECIS";


#-------------------------------------------------------------------------------
subtest {

  my Unicode::PRECIS::Identifier::UsernameCaseMapped $psid .= new;
  is $psid.calculate-value(0x0050), PVALID, 'Valid id character';
  is $psid.calculate-value(0x00B4), ID-DIS, 'Disallowed id character';
  is $psid.calculate-value(0x200C), CONTEXTJ, 'Allowed id character in context';

  my Str $username = 'Marcel';
  my TestValue $tv = $psid.prepare($username);
  ok (($tv ~~ Str) and ($tv eq lc($username))), "test username '$username'";

  $username = 'Marcel Timmerman';
  $tv = $psid.prepare($username);
  ok (($tv ~~ Bool) and not $tv), "test username '$username' fails";

  $username = "\x0646\x062c\x0645\x0629-\x0627\x0644\x0635\x0628\x0627\x062d";
  $tv = $psid.enforce($username);
  ok (($tv ~~ Str) and ($tv eq $username)), "test username '$username'";

  $username = "\x05d1\x05b7\x05bc\x05e8\x05e7\x05b7\x05d0\x05b4\x05d9";
  $tv = $psid.enforce($username);
  ok (($tv ~~ Str) and ($tv eq $username)), "test username '$username'";

  my Str $username1 = "ren\x[00E9]e";
  my Str $username2 = "rene\x[0301]e";
  ok $psid.compare( $username1, $username2),
     "Names $username1 and $username2 compare as being the same";

}, "Test Identifier case mapped profile";

#-------------------------------------------------------------------------------
done-testing;



#-------------------------------------------------------------------------------
sub test-match ( Int $codepoint, Str $category) {

  ok $codepoint.unimatch($category),
     chrs($codepoint) ~ " ($codepoint.fmt('0x%06x')) in $category set";
}

