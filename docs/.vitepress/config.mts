import { defineConfig, type DefaultTheme } from 'vitepress'

// Published at https://seesaw-earth.github.io/RodentFlow/ — every absolute link below is
// relative to this base. Change `base` if the repository is renamed.
const base = '/RodentFlow/'

function sidebarEn(): DefaultTheme.Sidebar {
  return [
    {
      text: 'Getting started',
      items: [
        { text: 'What is RodentFlow?', link: '/guide/introduction' },
        { text: 'Quick start', link: '/guide/getting-started' },
        { text: 'Recording videos that track well', link: '/guide/recording' }
      ]
    },
    {
      text: 'Using the app',
      items: [
        { text: 'Analyzing a video', link: '/guide/video-analysis' },
        { text: 'Manual entry & importing tables', link: '/guide/manual-and-import' },
        { text: 'Results', link: '/guide/results' },
        { text: 'Group analysis', link: '/guide/groups' }
      ]
    },
    {
      text: 'Assays',
      items: [
        { text: 'Overview', link: '/assays/' },
        { text: 'Anxiety & affect', link: '/assays/anxiety' },
        { text: 'Learning & memory', link: '/assays/memory' },
        { text: 'Motor function', link: '/assays/motor' },
        { text: 'Reward & decision', link: '/assays/reward' }
      ]
    },
    {
      text: 'How it works',
      items: [
        { text: 'Tracking', link: '/principles/tracking' },
        { text: 'From positions to metrics', link: '/principles/metrics' },
        { text: 'Statistics', link: '/principles/statistics' },
        { text: 'Validation', link: '/principles/validation' }
      ]
    },
    {
      text: 'Reference',
      items: [
        { text: 'Files & data', link: '/reference/files' },
        { text: 'FAQ & troubleshooting', link: '/reference/faq' },
        { text: 'Further reading', link: '/reference/reading' },
        { text: 'Release notes', link: '/reference/changelog' }
      ]
    },
    {
      text: 'About',
      items: [
        { text: 'Privacy policy', link: '/privacy' },
        { text: 'Support', link: '/support' }
      ]
    }
  ]
}

function sidebarZh(): DefaultTheme.Sidebar {
  return [
    {
      text: '入门',
      items: [
        { text: 'RodentFlow 是什么', link: '/zh/guide/introduction' },
        { text: '快速上手', link: '/zh/guide/getting-started' },
        { text: '怎样拍出好追踪的视频', link: '/zh/guide/recording' }
      ]
    },
    {
      text: '使用 App',
      items: [
        { text: '分析一段视频', link: '/zh/guide/video-analysis' },
        { text: '手动录入与导入表格', link: '/zh/guide/manual-and-import' },
        { text: '结果页', link: '/zh/guide/results' },
        { text: '组间分析', link: '/zh/guide/groups' }
      ]
    },
    {
      text: '实验范式',
      items: [
        { text: '总览', link: '/zh/assays/' },
        { text: '焦虑与情绪', link: '/zh/assays/anxiety' },
        { text: '学习与记忆', link: '/zh/assays/memory' },
        { text: '运动功能', link: '/zh/assays/motor' },
        { text: '奖赏与决策', link: '/zh/assays/reward' }
      ]
    },
    {
      text: '原理',
      items: [
        { text: '追踪原理', link: '/zh/principles/tracking' },
        { text: '从位置到指标', link: '/zh/principles/metrics' },
        { text: '统计方法', link: '/zh/principles/statistics' },
        { text: '验证', link: '/zh/principles/validation' }
      ]
    },
    {
      text: '参考',
      items: [
        { text: '文件与数据', link: '/zh/reference/files' },
        { text: '常见问题与排错', link: '/zh/reference/faq' },
        { text: '延伸阅读', link: '/zh/reference/reading' },
        { text: '版本说明', link: '/zh/reference/changelog' }
      ]
    },
    {
      text: '关于',
      items: [
        { text: '隐私政策', link: '/zh/privacy' },
        { text: '支持', link: '/zh/support' }
      ]
    }
  ]
}

export default defineConfig({
  base,
  title: 'RodentFlow',
  description: 'Rodent behavior tracking and analysis on iPhone — user manual',
  lastUpdated: false,
  cleanUrls: false,
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: `${base}favicon-64.png` }],
    ['link', { rel: 'apple-touch-icon', href: `${base}apple-touch-icon.png` }],
    ['meta', { name: 'theme-color', content: '#1f86c9' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'RodentFlow — user manual' }],
    ['meta', { property: 'og:image', content: `https://seesaw-earth.github.io${base}hero.png` }]
  ],
  markdown: {
    image: { lazyLoading: true }
  },
  themeConfig: {
    logo: '/logo.png',
    socialLinks: [{ icon: 'github', link: 'https://github.com/seesaw-earth/RodentFlow' }],
    search: {
      provider: 'local',
      options: {
        locales: {
          zh: {
            translations: {
              button: { buttonText: '搜索', buttonAriaLabel: '搜索' },
              modal: {
                displayDetails: '显示详细列表',
                resetButtonTitle: '清除',
                backButtonTitle: '关闭搜索',
                noResultsText: '没有找到',
                footer: { selectText: '选择', navigateText: '切换', closeText: '关闭' }
              }
            }
          }
        }
      }
    }
  },
  locales: {
    root: {
      label: 'English',
      lang: 'en-US',
      title: 'RodentFlow',
      description: 'Rodent behavior tracking and analysis on iPhone — user manual',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/guide/introduction', activeMatch: '/guide/' },
          { text: 'Assays', link: '/assays/', activeMatch: '/assays/' },
          { text: 'How it works', link: '/principles/tracking', activeMatch: '/principles/' },
          { text: 'Reference', link: '/reference/files', activeMatch: '/reference/' },
          { text: 'Support', link: '/support' }
        ],
        sidebar: sidebarEn(),
        outline: { level: [2, 3], label: 'On this page' },
        docFooter: { prev: 'Previous', next: 'Next' },
        footer: {
          message: 'RodentFlow · all analysis runs on the iPhone · <a href="/RodentFlow/privacy.html">Privacy</a> · <a href="/RodentFlow/support.html">Support</a>',
          copyright: '© 2026 Ziqing Shi'
        }
      }
    },
    zh: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/zh/',
      title: 'RodentFlow',
      description: '在 iPhone 上完成啮齿类动物行为追踪与分析 —— 使用手册',
      themeConfig: {
        nav: [
          { text: '指南', link: '/zh/guide/introduction', activeMatch: '/zh/guide/' },
          { text: '实验范式', link: '/zh/assays/', activeMatch: '/zh/assays/' },
          { text: '原理', link: '/zh/principles/tracking', activeMatch: '/zh/principles/' },
          { text: '参考', link: '/zh/reference/files', activeMatch: '/zh/reference/' },
          { text: '支持', link: '/zh/support' }
        ],
        sidebar: sidebarZh(),
        outline: { level: [2, 3], label: '本页目录' },
        docFooter: { prev: '上一页', next: '下一页' },
        langMenuLabel: '切换语言',
        returnToTopLabel: '回到顶部',
        sidebarMenuLabel: '目录',
        darkModeSwitchLabel: '外观',
        lightModeSwitchTitle: '切换到浅色模式',
        darkModeSwitchTitle: '切换到深色模式',
        skipToContentLabel: '跳到正文',
        notFound: {
          title: '页面不存在',
          quote: '这个地址没有内容，可能已经移动。',
          linkLabel: '回到首页',
          linkText: '回到首页'
        },
        footer: {
          message: 'RodentFlow · 所有分析都在 iPhone 本机完成 · <a href="/RodentFlow/zh/privacy.html">隐私政策</a> · <a href="/RodentFlow/zh/support.html">支持</a>',
          copyright: '© 2026 Ziqing Shi'
        }
      }
    }
  }
})
