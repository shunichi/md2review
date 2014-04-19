# coding: UTF-8
rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

if defined? Encoding
  Encoding.default_internal = 'UTF-8'
end

require 'test/unit'
require 'redcarpet'
require 'redcarpet/render/review'

class ReVIEWTest < Test::Unit::TestCase

  def setup
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::ReVIEW.new({}))
  end

  def render_with(flags, text)
    Redcarpet::Markdown.new(Redcarpet::Render::ReVIEW, flags).render(text)
  end

  def test_that_simple_one_liner_goes_to_review
    assert_respond_to @markdown, :render
    assert_equal "\n\nHello World.\n", @markdown.render("Hello World.")
  end

  def test_href
    assert_respond_to @markdown, :render
    assert_equal "\n\n@<href>{http://exmaple.com,example}\n", @markdown.render("[example](http://exmaple.com)")
  end

  def test_href_with_comma
    assert_respond_to @markdown, :render
    assert_equal "\n\n@<href>{http://exmaple.com/foo\\,bar,example}\n", @markdown.render("[example](http://exmaple.com/foo,bar)")
  end

  def test_header
    assert_respond_to @markdown, :render
    assert_equal "\n= AAA\n\n\nBBB\n\n== ccc\n\n\nddd\n", @markdown.render("#AAA\nBBB\n\n##ccc\n\nddd\n")
  end

  def test_code_fence_with_caption
    rd = render_with({:fenced_code_blocks => true}, %Q[~~~ {caption="test"}\ndef foo\n  p "test"\nend\n~~~\n])
    assert_equal %Q[\n//emlist[test]{\ndef foo\n  p "test"\nend\n//}\n], rd
  end

  def test_code_fence_without_flag
    rd = render_with({}, %Q[~~~ {caption="test"}\ndef foo\n  p "test"\nend\n~~~\n])
    assert_equal %Q[\n\n~~~ {caption="test"}\ndef foo\n  p "test"\nend\n~~~\n], rd
  end

  def test_group_ruby
    rd = render_with({:ruby => true}, "{電子出版|でんししゅっぱん}を手軽に\n")
    assert_equal %Q[\n\n@<ruby>{電子出版,でんししゅっぱん}を手軽に\n], rd
  end

  def test_tcy
    rd = render_with({:tcy => true}, "昭和^53^年\n")
    assert_equal %Q[\n\n昭和@<tcy>{53}年\n], rd
  end

  def test_footnote
    rd = render_with({:footnotes=>true}, "これは脚注付き[^1]の段落です。\n\n[^1]: そして、これが脚注です。\n")
    assert_equal %Q|\n\nこれは脚注付き@<fn>{1}の段落です。\n\n//footnote[1][そして、これが脚注です。]\n|, rd
  end
end
