(function () {
  'use strict';
  var root = document.documentElement;
  var themeButton = document.getElementById('theme-button');
  function syncTheme() {
    var dark = root.dataset.theme === 'dark';
    if (themeButton) {
      themeButton.setAttribute('aria-pressed', String(dark));
      themeButton.setAttribute('aria-label', dark ? '切换浅色模式' : '切换深色模式');
    }
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.content = getComputedStyle(document.body).backgroundColor;
  }
  if (themeButton) themeButton.addEventListener('click', function () {
    root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
    try { localStorage.setItem('terminus-theme', root.dataset.theme); } catch (e) {}
    syncTheme();
  });
  syncTheme();

  var dialog = document.getElementById('search-dialog');
  if (!dialog) return;
  var input = document.getElementById('search-input');
  var results = document.getElementById('results-container');
  var status = document.getElementById('search-status');
  var index;
  var loading;
  var opener;

  async function loadIndex() {
    if (index) return index;
    if (!loading) loading = fetch(dialog.dataset.searchUrl).then(function (response) {
      if (!response.ok) throw new Error('Search index unavailable');
      return response.json();
    }).then(function (posts) { index = posts; return posts; }).catch(function (error) {
      loading = null;
      throw error;
    });
    return loading;
  }
  async function search() {
    var query = input.value.trim().toLocaleLowerCase();
    results.replaceChildren();
    if (!query) { status.textContent = '输入关键词，搜索标题、标签和正文。'; return; }
    status.textContent = '正在查找…';
    try {
      var posts = await loadIndex();
      if (query !== input.value.trim().toLocaleLowerCase()) return;
      var terms = query.split(/\s+/);
      var matches = posts.filter(function (post) {
        var text = [post.title, (post.tags || []).join(' '), post.description, post.content].join(' ').toLocaleLowerCase();
        return terms.every(function (term) { return text.includes(term); });
      });
      status.textContent = matches.length ? '找到 ' + matches.length + ' 篇文章' : '暂时没有找到。试试其他关键词？';
      matches.forEach(function (post) {
        var li = document.createElement('li');
        var link = document.createElement('a');
        var url = new URL(post.url, location.origin);
        if (url.origin !== location.origin) return;
        link.href = url.href;
        link.textContent = post.title;
        var meta = document.createElement('small');
        meta.textContent = (post.date || '').slice(0, 10) + ' / ' + (post.tags || []).join(', ');
        link.append(meta);
        li.append(link);
        results.append(li);
      });
    } catch (e) {
      if (query === input.value.trim().toLocaleLowerCase()) status.textContent = '搜索暂时不可用，请稍后重试，或从文章页面浏览。';
    }
  }
  function openSearch() {
    if (dialog.open) return;
    opener = document.activeElement;
    dialog.showModal();
    input.focus();
    search();
  }
  function closeSearch() { dialog.close(); }
  document.querySelectorAll('.search-open').forEach(function (button) { button.addEventListener('click', openSearch); });
  dialog.querySelector('.search-close').addEventListener('click', closeSearch);
  dialog.addEventListener('close', function () { if (opener && opener.focus) opener.focus(); });
  dialog.addEventListener('click', function (event) {
    var box = dialog.getBoundingClientRect();
    if (event.target === dialog && (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom)) closeSearch();
  });
  input.addEventListener('input', search);
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && dialog.open) { event.preventDefault(); closeSearch(); }
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') { event.preventDefault(); openSearch(); }
  });
  window.toggle_comments = function () {
    var curtain = document.getElementById('comment-curtain');
    var layout = document.getElementById('comment-layout');
    if (curtain) curtain.classList.add('hide');
    if (layout) layout.classList.add('show');
  };
  if (!document.getElementById('comment-curtain')) {
    var comments = document.getElementById('comment-layout');
    if (comments) comments.classList.add('show');
  }
})();
