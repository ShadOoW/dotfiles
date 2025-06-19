# Qutebrowser Configuration - Power User Setup
# Location: ~/.config/qutebrowser/config.py

import os
from qutebrowser.config.configfiles import ConfigAPI
from qutebrowser.config.config import ConfigContainer

config: ConfigAPI = config
c: ConfigContainer = c

# Load autoconfig (GUI settings)
config.load_autoconfig()

# ============================================================================
# GENERAL SETTINGS
# ============================================================================

# Automatically save the config file on exit
c.auto_save.session = False

# Always restore open sites when qutebrowser is reopened
c.auto_save.interval = 15000

# Disable crash report and restore dialogs
c.session.default_name = None

# Backend to use to display websites
c.backend = 'webengine'

# Disable crash reporter and startup messages
c.messages.timeout = 5000
c.qt.chromium.low_end_device_mode = 'auto'

# Disable crash report dialog and session restoraion messages
c.session.lazy_restore = False

# Disable QtWebEngine crash reporter
c.qt.args = ['--disable-crash-reporter', '--disable-logging', '--silent']

# ============================================================================
# CONTENT SETTINGS & PRIVACY
# ============================================================================

# Enable adblock (requires python-adblock package)
# Install with: pip install adblock or from AUR: python-adblock
try:
    c.content.blocking.enabled = True
    c.content.blocking.method = 'both'
    
    # AdBlock lists (only set if adblock is available)
    c.content.blocking.adblock.lists = [
        'https://easylist.to/easylist/easylist.txt',
        'https://easylist.to/easylist/easyprivacy.txt',
        'https://secure.fanboy.co.nz/fanboy-annoyance.txt',
        'https://easylist.to/easylist/fanboy-social.txt',
        'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt',
        'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt',
        'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt'
    ]
except Exception:
    # Fallback if adblock is not available
    c.content.blocking.enabled = False

# Privacy settings
c.content.cookies.accept = 'no-3rdparty'
c.content.cookies.store = True
c.content.geolocation = 'ask'
c.content.notifications.enabled = False
c.content.autoplay = False
c.content.canvas_reading = False
c.content.webgl = True
c.content.hyperlink_auditing = False

# JavaScript settings
c.content.javascript.enabled = True
c.content.javascript.clipboard = 'access'
c.content.javascript.can_close_tabs = False
c.content.javascript.can_open_tabs_automatically = False

# Media settings
c.content.media.audio_capture = 'ask'
c.content.media.video_capture = 'ask'
c.content.media.audio_video_capture = 'ask'

# Headers
c.content.headers.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
c.content.headers.do_not_track = True
c.content.headers.referer = 'same-domain'

# ============================================================================
# DOWNLOADS
# ============================================================================

c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = False
c.downloads.location.remember = True
c.downloads.remove_finished = 10000

# ============================================================================
# SEARCH ENGINES
# ============================================================================

c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'g': 'https://www.google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'aw': 'https://wiki.archlinux.org/index.php?search={}',
    'aur': 'https://aur.archlinux.org/packages/?O=0&K={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'reddit': 'https://www.reddit.com/search/?q={}',
    'so': 'https://stackoverflow.com/search?q={}',
    'mdn': 'https://developer.mozilla.org/en-US/search?q={}',
    'wiki': 'https://en.wikipedia.org/wiki/Special:Search?search={}'
}

# Start page and default page
c.url.start_pages = ['about:blank']
c.url.default_page = 'about:blank'

# ============================================================================
# TABS
# ============================================================================

c.tabs.background = True
c.tabs.last_close = 'close'
c.tabs.new_position.related = 'next'
c.tabs.new_position.unrelated = 'last'
c.tabs.position = 'top'
c.tabs.show = 'multiple'
c.tabs.title.format = '{audio}{index}: {current_title}'
c.tabs.title.format_pinned = '{audio}{index}'
c.tabs.close_mouse_button = 'middle'
c.tabs.mousewheel_switching = True

# ============================================================================
# WINDOW & UI
# ============================================================================

c.window.title_format = '{perc}{current_title}{title_sep}qutebrowser'
c.window.transparent = False

# Scrollbars
c.scrolling.bar = 'when-searching'
c.scrolling.smooth = False

# Status bar
c.statusbar.show = 'in-mode'
c.statusbar.position = 'bottom'

# Completion
c.completion.height = '50%'
c.completion.shrink = True
c.completion.use_best_match = True

# ============================================================================
# FONTS
# ============================================================================

c.fonts.completion.entry = '11pt monospace'
c.fonts.completion.category = 'bold 11pt monospace'
c.fonts.debug_console = '11pt monospace'
c.fonts.downloads = '11pt monospace'
c.fonts.hints = 'bold 12pt monospace'
c.fonts.keyhint = '11pt monospace'
c.fonts.messages.error = '11pt monospace'
c.fonts.messages.info = '11pt monospace'
c.fonts.messages.warning = '11pt monospace'
c.fonts.prompts = '11pt sans-serif'
c.fonts.statusbar = '11pt monospace'
c.fonts.tabs.selected = '11pt monospace'
c.fonts.tabs.unselected = '11pt monospace'
c.fonts.web.family.standard = 'Liberation Sans'
c.fonts.web.family.fixed = 'Liberation Mono'
c.fonts.web.family.serif = 'Liberation Serif'
c.fonts.web.family.sans_serif = 'Liberation Sans'
c.fonts.web.size.default = 16
c.fonts.web.size.default_fixed = 13

# ============================================================================
# COLORS & THEME
# ============================================================================

# Dark theme
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'never'
c.colors.webpage.darkmode.threshold.foreground = 150
c.colors.webpage.darkmode.threshold.background = 100

# ============================================================================
# KEYBINDINGS
# ============================================================================

# Clear default bindings that conflict with custom ones
config.unbind('d', mode='normal')
config.unbind('u', mode='normal')

# Navigation
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('H', 'back')
config.bind('L', 'forward')

# Scrolling
config.bind('j', 'scroll down')
config.bind('k', 'scroll up')
config.bind('h', 'scroll left')
config.bind('l', 'scroll right')
config.bind('<Ctrl-u>', 'scroll-page 0 -0.5')
config.bind('<Ctrl-d>', 'scroll-page 0 0.5')

# Tabs
config.bind('t', 'cmd-set-text -s :open -t')
config.bind('T', 'cmd-set-text -s :open -t {url:pretty}')
config.bind('x', 'tab-close')
config.bind('X', 'undo')
config.bind('gT', 'tab-move -1')
config.bind('gt', 'tab-move +1')
config.bind('<Ctrl-Shift-T>', 'undo')

# Downloads
config.bind('gd', 'download-clear')

# Zoom
config.bind('+', 'zoom-in')
config.bind('=', 'zoom-in')
config.bind('-', 'zoom-out')
config.bind('0', 'zoom')

# Developer tools
config.bind('<F12>', 'devtools')

# Bookmarks
config.bind('B', 'bookmark-add')
config.bind('gb', 'bookmark-list')

# Quickmarks
config.bind('M', 'quickmark-save')
config.bind('m', 'quickmark-load')

# Source and reader mode
config.bind('gs', 'view-source')
config.bind('gr', 'reader')

# ============================================================================
# HINTS
# ============================================================================

c.hints.chars = 'asdfghjkl'
c.hints.auto_follow = 'unique-match'
c.hints.auto_follow_timeout = 100
c.hints.min_chars = 1
c.hints.scatter = True
c.hints.uppercase = False

# ============================================================================
# EDITOR
# ============================================================================

c.editor.command = ['nvim', '{}']

# ============================================================================
# SPELLCHECK
# ============================================================================

# Spellcheck disabled - install dictionaries manually if needed
# c.spellcheck.languages = ['en-US']

# ============================================================================
# ALIASES
# ============================================================================

c.aliases = {
    'w': 'session-save',
    'q': 'close',
    'qa': 'quit',
    'wq': 'quit --save',
    'wqa': 'quit --save',
    'h': 'help',
    'clear-cache': 'clear-keystore ;; clear-messages ;; history-clear ;; download-clear',
    'adblock-update': 'adblock-update',
    'private': 'open -p',
    'reader': 'reader',
    'dev': 'devtools'
}

# ============================================================================
# QUICKMARKS (Examples)
# ============================================================================

# Quickmarks are set using the quickmark-add command or GUI
# Example: :quickmark-add arch https://archlinux.org
# These can be accessed with 'm' key followed by the shortcut

# ============================================================================
# PER-DOMAIN SETTINGS
# ============================================================================

# Allow autoplay for media sites
config.set('content.autoplay', True, 'https://www.youtube.com')
config.set('content.autoplay', True, 'https://youtube.com')
config.set('content.autoplay', True, 'https://netflix.com')

# JavaScript whitelist for essential sites
config.set('content.javascript.enabled', True, 'https://github.com')
config.set('content.javascript.enabled', True, 'https://gmail.com')
config.set('content.javascript.enabled', True, 'https://google.com')

# Cookies for essential sites
config.set('content.cookies.accept', 'all', 'https://gmail.com')
config.set('content.cookies.accept', 'all', 'https://github.com')

# ============================================================================
# PERFORMANCE SETTINGS
# ============================================================================

# Memory and cache settings
c.content.cache.size = 52428800  # 50MB
c.session.lazy_restore = True

# Network settings
c.content.dns_prefetch = True

# ============================================================================
# SECURITY SETTINGS
# ============================================================================

c.content.tls.certificate_errors = 'ask-block-thirdparty'
c.content.xss_auditing = True

# ============================================================================
# COMPLETION
# ============================================================================

c.completion.web_history.max_items = 1000
c.completion.cmd_history_max_items = 100

# Load local settings if they exist
config_dir = os.path.expanduser('~/.config/qutebrowser')
local_config = os.path.join(config_dir, 'local_config.py')
if os.path.exists(local_config):
    config.source(local_config) 
 
