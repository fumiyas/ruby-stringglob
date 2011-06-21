require 'stringglob'
require 'test/unit'

SG = StringGlob

class StringGlobTest < Test::Unit::TestCase
  def test_all
    regexp = SG.regexp('foo')
    assert_not_nil regexp.match('foo')
    assert_nil regexp.match('foobar')

    ## absolute string
    assert_not_nil	SG.regexp('foo').match('foo')
    assert_nil		SG.regexp('foo').match('foobar')

    ## * wildcard
    assert_not_nil	SG.regexp('foo.*').match('foo.')
    assert_not_nil	SG.regexp('foo.*').match('foo.bar')
    assert_nil		SG.regexp('foo.*').match('gfoo.bar')

    ## ? wildcard
    assert_not_nil	SG.regexp('foo.?p').match('foo.cp')
    assert_nil		SG.regexp('foo.?p').match('foo.cd')

    ## .{alternation,or,something}
    assert_not_nil	SG.regexp('foo.{c,h}').match('foo.h')
    assert_not_nil	SG.regexp('foo.{c,h}').match('foo.c')
    assert_nil		SG.regexp('foo.{c,h}').match('foo.o')

    ## \escaping
    assert_not_nil	SG.regexp('foo.\\{c,h}\\*').match('foo.{c,h}*')
    assert_nil		SG.regexp('foo.\\{c,h}\\*').match('foo.\\c')

    ## escape ()
    assert_not_nil	SG.regexp('foo.(bar)').match('foo.(bar)')

    ## strict . rule fail
    assert_nil		SG.regexp('*.foo').match('.file.foo')
    ## strict . rule match
    assert_not_nil	SG.regexp('.*.foo').match('.file.foo')
    ## relaxed . rule
    assert_not_nil	SG.regexp('*.foo', SG::NO_STRICT_LEADING_DOT).match('.file.foo')

    ## strict wildcard / fail
    assert_nil		SG.regexp('*.fo?').match('foo/file.fob')
    ## strict wildcard / match
    assert_not_nil	SG.regexp('*/*.fo?').match('foo/file.fob')
    ## relaxed wildcard /
    assert_not_nil	SG.regexp('*.fo?', SG::NO_STRICT_WILDCARD_SLASH).match('foo/file.fob')

    ## more strict wildcard / fail
    assert_nil		SG.regexp('foo/*.foo').match('foo/.foo')
    ## more strict wildcard / match
    assert_not_nil	SG.regexp('foo/.f*').match('foo/.foo')
    ## relaxed wildcard /
    assert_not_nil	SG.regexp('*.foo', SG::NO_STRICT_WILDCARD_SLASH).match('foo/.foo')

    ## properly escape +
    assert_not_nil	SG.regexp('f+.foo').match('f+.foo')
    assert_nil		SG.regexp('f+.foo').match('ffff.foo')

    ## handle embedded \\n
    assert_not_nil	SG.regexp("foo\nbar").match("foo\nbar")
    assert_nil		SG.regexp("foo\nbar").match("foobar")

    ## [abc]
    assert_not_nil	SG.regexp('test[abc]').match('testa')
    assert_not_nil	SG.regexp('test[abc]').match('testb')
    assert_not_nil	SG.regexp('test[abc]').match('testc')
    assert_nil		SG.regexp('test[abc]').match('testd')

    ## escaping \$
    assert_not_nil	SG.regexp('foo$bar.*').match('foo$bar.c')

    ## escaping ^
    assert_not_nil	SG.regexp('foo^bar.*').match('foo^bar.c')

    ## escaping |
    assert_not_nil	SG.regexp('foo|bar.*').match('foo|bar.c')


    ## {foo,{bar,baz}}
    assert_not_nil	SG.regexp('{foo,{bar,baz}}').match('foo')
    assert_not_nil	SG.regexp('{foo,{bar,baz}}').match('bar')
    assert_not_nil	SG.regexp('{foo,{bar,baz}}').match('baz')
    assert_nil		SG.regexp('{foo,{bar,baz}}').match('foz')

    ## @ character
    assert_not_nil	SG.regexp('foo@bar').match('foo@bar')
    ## $ character
    assert_not_nil	SG.regexp('foo$bar').match('foo$bar')
    ## % character
    assert_not_nil	SG.regexp('foo%bar').match('foo%bar')

    ## ** wildcard and path components
    assert_not_nil	SG.regexp('foo/*/baz').match('foo/bar/baz')
    assert_nil		SG.regexp('foo/*/baz').match('foo/bar/bar/baz')
    assert_nil		SG.regexp('foo/**/baz').match('foo/baz')
    assert_not_nil	SG.regexp('foo/**/baz').match('foo/bar/baz')
    assert_not_nil	SG.regexp('foo/**/baz').match('foo/bar/bar/baz')
    assert_nil		SG.regexp('foo/**').match('foo')
    assert_not_nil	SG.regexp('foo/**').match('foo/bar')
    assert_not_nil	SG.regexp('foo/**').match('foo/bar/baz')
    assert_nil		SG.regexp('**/foo').match('foo')
    assert_not_nil	SG.regexp('**/foo').match('bar/foo')
    assert_not_nil	SG.regexp('**/foo').match('baz/bar/foo')
    ## escaping ** wildcard
    assert_nil		SG.regexp('foo/\\**/baz').match('foo/bar/baz')
    assert_not_nil	SG.regexp('foo/\\**/baz').match('foo/*bar/baz')
    assert_nil		SG.regexp('foo/*\\*/baz').match('foo/bar/baz')
    assert_not_nil	SG.regexp('foo/*\\*/baz').match('foo/bar*/baz')
  end
end

