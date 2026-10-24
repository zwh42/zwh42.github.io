# Run after a production build: bundle exec ruby scripts/check_site.rb /path/to/site
require 'jekyll'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

root = File.expand_path(ARGV.fetch(0, '_site'))
source = File.expand_path('..', __dir__)
def check(condition, message)
  abort "FAIL: #{message}" unless condition
end

taxonomy_template = File.read(File.join(source, '_includes/taxonomy-value.html'))
rules = YAML.load_file(File.join(source, '_data/taxonomy.yml'))
fixtures = [
  ['categories', { 'title' => 'GPU', 'categories' => ['自定义', '第二分类'] }, '自定义|第二分类'],
  ['categories', { 'title' => 'GPU', 'categories' => ['自定义', '自定义'] }, '自定义'],
  ['categories', { 'title' => 'GPU 光刻仿真工具' }, '算力与工具'],
  ['categories', { 'title' => '曲线掩模走到哪一步了', 'tags' => ['ILT'] }, '掩模工艺'],
  ['categories', { 'title' => '一篇没有领域关键词的文章', 'tags' => ['光学'] }, '光学成像'],
  ['categories', { 'title' => '读书时想到的一件事', 'tags' => [] }, '随笔'],
  ['tags', { 'title' => 'ILT 与 OPC', 'tags' => ['原有标签', '原有标签'] }, '原有标签'],
  ['tags', { 'title' => '用 KLayout 和 Python 处理版图', 'tags' => [] }, 'KLayout|Python'],
  ['tags', { 'title' => '一次阅读', 'description' => '光学与傅里叶', 'tags' => [] }, '光学'],
  ['tags', { 'title' => '没有关键词', 'tags' => [] }, '']
]
fixtures.each do |kind, post, expected|
  actual = Liquid::Template.parse(taxonomy_template).render!(
    'include' => { 'kind' => kind, 'post' => post }, 'site' => { 'data' => { 'taxonomy' => rules } }
  )
  check(actual == expected, "#{kind} inference for #{post['title']}: #{actual.inspect}")
end
puts "PASS: #{fixtures.size} metadata inference/override cases"

posts = JSON.parse(File.read(File.join(root, 'search.json')))
check(posts.size == Dir[File.join(source, '_posts/*')].size, 'search index contains every post')
check(posts.all? { |post| post['categories'].is_a?(Array) && !post['categories'].empty? && post['tags'].is_a?(Array) }, 'metadata arrays in search index')
categories = posts.flat_map { |post| post['categories'] }.tally
tags = posts.flat_map { |post| post['tags'] }.tally

%w[categories archive blog].each do |page|
  doc = Nokogiri::HTML(File.read(File.join(root, page, 'index.html')))
  actual_categories = doc.css('.category-card').to_h do |card|
    term = URI.decode_www_form(URI(card['href']).query).to_h.fetch('category')
    [term, card.at_css('.category-count').text.to_i]
  end
  actual_tags = doc.css('.tag-cloud a').to_h do |link|
    term = URI.decode_www_form(URI(link['href']).query).to_h.fetch('tag')
    [term, link.at_css('.tag-count').text.to_i]
  end
  check(actual_categories == categories, "category counts on /#{page}/")
  check(actual_tags == tags, "tag counts on /#{page}/")
  check(doc.css('.timeline-list a').map { |link| link['href'] } == posts.map { |post| post['url'] }, "timeline order on /#{page}/")
  check(doc.css('pre code').none? { |code| code.text.include?('archive-year') || code.text.include?('<section') }, "no escaped HTML on /#{page}/")
end
%w[category tag].each do |page|
  key = page == 'tag' ? 'tags' : 'categories'
  doc = Nokogiri::HTML(File.read(File.join(root, page, 'index.html')))
  doc.css('.taxonomy-group').each do |group|
    expected = posts.select { |post| post[key].include?(group['data-term']) }.map { |post| post['url'] }
    check(group.css('.filtered-posts h3 a').map { |link| link['href'] } == expected, "#{page} membership for #{group['data-term']}")
  end
end
puts "PASS: #{posts.size} posts, #{categories.size} categories, #{tags.size} tags; counts, groups and timelines agree"

routes = ['/', '/categories/', '/archive/', '/blog/', '/tags/', '/tag/', '/category/', '/about/', '/portfolio/', '/lithography/', '/404.html']
home_pages = Dir[File.join(root, 'page*/index.html')]
routes += home_pages.map { |path| path.delete_prefix(root).delete_suffix('index.html') }
routes += posts.map { |post| post['url'] }
link_count = 0
routes.each do |route|
  path = File.join(root, route.end_with?('/') ? route + 'index.html' : route)
  check(File.file?(path), "route exists: #{route}")
  doc = Nokogiri::HTML(File.read(path))
  page_headings = doc.css('h1').reject { |heading| heading.ancestors('.article-body').any? }
  check(page_headings.size == 1, "one page heading on #{route}")
  check(doc.css('.site-header').size == 1 && doc.css('.site-footer').size == 1, "shared design on #{route}")
  check(doc.css('[id]').map { |node| node['id'] }.tally.values.all? { |count| count == 1 }, "unique IDs on #{route}")
  doc.css('a[href], img[src], script[src], link[rel=stylesheet]').each do |node|
    value = node['href'] || node['src']
    next if value.empty? || value.start_with?('#', 'http:', 'https:', 'mailto:', 'data:')
    target = URI.join('http://local.test' + route, value).path
    local = File.join(root, URI::DEFAULT_PARSER.unescape(target))
    local = File.join(local, 'index.html') if File.directory?(local)
    check(File.file?(local), "local asset/link exists on #{route}: #{value}")
    link_count += 1
  end
end
puts "PASS: #{routes.size} pages share the design; #{link_count} local links/assets resolve"
