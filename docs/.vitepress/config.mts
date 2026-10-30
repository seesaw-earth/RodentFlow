import { defineConfig, type DefaultTheme } from 'vitepress'

// Published at https://seesaw-earth.github.io/RodentFlow/ — every absolute link below is
// relative to this base. Change `base` if the repository is renamed.
// The home pages (/ and /zh/) are not VitePress pages: they are docs/public/index.html and
// docs/public/zh/index.html, a standalone showcase page with its own styles and script.
const base = '/RodentFlow/'

function sidebarEn(): DefaultTheme.Sidebar {
  return [
    {
      text: 'Getting started',
      items: [
        { text: 'Which edition do I need?', link: '/guide/editions' },
        { text: 'Centroid tracking on iPhone', link: '/guide/introduction' },
        { text: 'Quick start on iPhone', link: '/guide/getting-started' },
        { text: 'Recording videos that track well', link: '/guide/recording' },
        { text: 'Before you record: pose, limb & Mac', link: '/guide/recording-pose' }
      ]
    },
    {
      text: 'iPhone & iPad',
      items: [
        { text: 'Analyzing a video', link: '/guide/video-analysis' },
        { text: 'Manual entry & importing tables', link: '/guide/manual-and-import' },
        { text: 'Results', link: '/guide/results' },
        { text: 'Group analysis', link: '/guide/groups' },
        { text: 'Pose tracking on iPhone & iPad', link: '/guide/pose-iphone-ipad' }
      ]
    },
    {
      text: 'Mac',
      items: [
        { text: 'RodentFlow for Mac', link: '/mac/' },
        { text: 'Quick start on Mac', link: '/mac/quick-start' },
        { text: 'The full workflow', link: '/mac/workflow' },
        { text: 'Multi-chamber tail suspension', link: '/mac/tst' },
        { text: 'Group comparison & statistics', link: '/mac/compare' },
        { text: 'Exports explained', link: '/mac/exports' },
        { text: 'Keyboard shortcuts', link: '/mac/shortcuts' }
      ]
    },
    {
      text: 'Assays',
      items: [
        { text: 'Overview', link: '/assays/' },
        { text: 'Anxiety & affect', link: '/assays/anxiety' },
        { text: 'Learning & memory', link: '/assays/memory' },
        { text: 'Motor function', link: '/assays/motor' },
        { text: 'Reward & decision', link: '/assays/reward' },
        { text: 'Pose, limb & Mac assays', link: '/assays/pose' }
      ]
    },
    {
      text: 'How it works',
      items: [
        { text: 'Tracking', link: '/principles/tracking' },
        { text: 'From positions to metrics', link: '/principles/metrics' },
        { text: 'Statistics', link: '/principles/statistics' },
        { text: 'Validation', link: '/principles/validation' },
        { text: 'Getting results you can trust', link: '/principles/good-practice' }
      ]
    },
    {
      text: 'Models & tutorials',
      items: [
        { text: 'Core ML models', link: '/models' },
        { text: 'Tutorials: overview', link: '/tutorials/' },
        { text: '1 · MousePose6', link: '/tutorials/mousepose6' },
        { text: '2 · CylinderMousePoseV2', link: '/tutorials/cylinder-v2' },
        { text: '3 · TST mouse detector', link: '/tutorials/tst-detector' },
        { text: '4 · Core ML in the app', link: '/tutorials/app-integration' },
        { text: 'How to cite', link: '/tutorials/citations' }
      ]
    },
    {
      text: 'Reference',
      items: [
        { text: 'Files & data', link: '/reference/files' },
        { text: 'Where your data lives & backups', link: '/reference/data-and-backups' },
        { text: 'FAQ & troubleshooting', link: '/reference/faq' },
        { text: 'Troubleshooting: Mac & pose', link: '/reference/troubleshooting-mac' },
        { text: 'Further reading', link: '/reference/reading' },
        { text: 'Assay protocols & related tools', link: '/reference/protocols' },
        { text: 'Release notes', link: '/reference/changelog' }
      ]
    },
    {
      text: 'About',
      items: [
        { text: 'Source code', link: '/source' },
        { text: 'Privacy policy', link: '/privacy' },
        { text: 'Support', link: '/support' },
        { text: 'Legal & notices', link: '/legal' },
        { text: 'Accessibility', link: '/accessibility' }
      ]
    }
  ]
}

function sidebarZh(): DefaultTheme.Sidebar {
  return [
    {
      text: '入门',
      items: [
        { text: '我该用哪个版本？', link: '/zh/guide/editions' },
        { text: 'iPhone 上的质心追踪', link: '/zh/guide/introduction' },
        { text: 'iPhone 快速上手', link: '/zh/guide/getting-started' },
        { text: '怎样拍出好追踪的视频', link: '/zh/guide/recording' },
        { text: '拍摄之前：姿态、肢体与 Mac', link: '/zh/guide/recording-pose' }
      ]
    },
    {
      text: 'iPhone 与 iPad',
      items: [
        { text: '分析一段视频', link: '/zh/guide/video-analysis' },
        { text: '手动录入与导入表格', link: '/zh/guide/manual-and-import' },
        { text: '结果页', link: '/zh/guide/results' },
        { text: '组间分析', link: '/zh/guide/groups' },
        { text: 'iPhone 与 iPad 上的姿态追踪', link: '/zh/guide/pose-iphone-ipad' }
      ]
    },
    {
      text: 'Mac',
      items: [
        { text: 'RodentFlow Mac 版', link: '/zh/mac/' },
        { text: 'Mac 快速上手', link: '/zh/mac/quick-start' },
        { text: '完整流程', link: '/zh/mac/workflow' },
        { text: '多格悬尾实验', link: '/zh/mac/tst' },
        { text: '组间比较与统计', link: '/zh/mac/compare' },
        { text: '导出文件说明', link: '/zh/mac/exports' },
        { text: '键盘快捷键', link: '/zh/mac/shortcuts' }
      ]
    },
    {
      text: '实验范式',
      items: [
        { text: '总览', link: '/zh/assays/' },
        { text: '焦虑与情绪', link: '/zh/assays/anxiety' },
        { text: '学习与记忆', link: '/zh/assays/memory' },
        { text: '运动功能', link: '/zh/assays/motor' },
        { text: '奖赏与决策', link: '/zh/assays/reward' },
        { text: '姿态、肢体与 Mac 范式', link: '/zh/assays/pose' }
      ]
    },
    {
      text: '原理',
      items: [
        { text: '追踪原理', link: '/zh/principles/tracking' },
        { text: '从位置到指标', link: '/zh/principles/metrics' },
        { text: '统计方法', link: '/zh/principles/statistics' },
        { text: '验证', link: '/zh/principles/validation' },
        { text: '让结果经得起检验', link: '/zh/principles/good-practice' }
      ]
    },
    {
      text: '模型与教程',
      items: [
        { text: 'Core ML 模型', link: '/zh/models' },
        { text: '教程概览', link: '/zh/tutorials/' },
        { text: '1 · MousePose6', link: '/zh/tutorials/mousepose6' },
        { text: '2 · CylinderMousePoseV2', link: '/zh/tutorials/cylinder-v2' },
        { text: '3 · 悬尾实验小鼠检测器', link: '/zh/tutorials/tst-detector' },
        { text: '4 · App 里的 Core ML', link: '/zh/tutorials/app-integration' },
        { text: '如何引用', link: '/zh/tutorials/citations' }
      ]
    },
    {
      text: '参考',
      items: [
        { text: '文件与数据', link: '/zh/reference/files' },
        { text: '数据存放位置与备份', link: '/zh/reference/data-and-backups' },
        { text: '常见问题与排错', link: '/zh/reference/faq' },
        { text: '排查：Mac 与姿态追踪', link: '/zh/reference/troubleshooting-mac' },
        { text: '延伸阅读', link: '/zh/reference/reading' },
        { text: '实验方案与相关工具', link: '/zh/reference/protocols' },
        { text: '版本说明', link: '/zh/reference/changelog' }
      ]
    },
    {
      text: '关于',
      items: [
        { text: '源代码', link: '/zh/source' },
        { text: '隐私政策', link: '/zh/privacy' },
        { text: '支持', link: '/zh/support' },
        { text: '法律与声明', link: '/zh/legal' },
        { text: '无障碍', link: '/zh/accessibility' }
      ]
    }
  ]
}

export default defineConfig({
  base,
  title: 'RodentFlow',
  description: 'Rodent behavior tracking and analysis on iPhone, iPad and Mac — user manual',
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
    logoLink: { link: base, target: '_self' },
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
      description: 'Rodent behavior tracking and analysis on iPhone, iPad and Mac — user manual',
      themeConfig: {
        nav: [
          {
            text: 'Manual',
            activeMatch: '^/(guide|mac|assays|principles|reference)/',
            items: [
              { text: 'Getting started', link: '/guide/editions' },
              { text: 'iPhone & iPad', link: '/guide/video-analysis' },
              { text: 'Mac', link: '/mac/' },
              { text: 'Assays', link: '/assays/' },
              { text: 'How it works', link: '/principles/tracking' },
              { text: 'Reference', link: '/reference/files' }
            ]
          },
          { text: 'Models & tutorials', link: '/models', activeMatch: '^/(models|tutorials/)' },
          { text: 'Source code', link: '/source' },
          { text: 'Support', link: '/support' }
        ],
        sidebar: sidebarEn(),
        outline: { level: [2, 3], label: 'On this page' },
        docFooter: { prev: 'Previous', next: 'Next' },
        editLink: {
          pattern: 'https://github.com/seesaw-earth/RodentFlow/edit/main/docs/:path',
          text: 'Edit this page on GitHub'
        },
        footer: {
          message: 'RodentFlow for iPhone, iPad and Mac · <a href="/RodentFlow/source.html">Source code</a> · <a href="/RodentFlow/privacy.html">Privacy</a> · <a href="/RodentFlow/support.html">Support</a> · <a href="/RodentFlow/legal.html">Legal</a>',
          copyright: '© 2026 Ziqing Shi'
        }
      }
    },
    zh: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/zh/',
      title: 'RodentFlow',
      description: '在 iPhone、iPad 和 Mac 上完成啮齿类动物行为追踪与分析 —— 使用手册',
      themeConfig: {
        logoLink: { link: `${base}zh/`, target: '_self' },
        nav: [
          {
            text: '手册',
            activeMatch: '^/zh/(guide|mac|assays|principles|reference)/',
            items: [
              { text: '入门', link: '/zh/guide/editions' },
              { text: 'iPhone 与 iPad', link: '/zh/guide/video-analysis' },
              { text: 'Mac 版', link: '/zh/mac/' },
              { text: '实验范式', link: '/zh/assays/' },
              { text: '原理', link: '/zh/principles/tracking' },
              { text: '参考', link: '/zh/reference/files' }
            ]
          },
          { text: '模型与教程', link: '/zh/models', activeMatch: '^/zh/(models|tutorials/)' },
          { text: '源代码', link: '/zh/source' },
          { text: '支持', link: '/zh/support' }
        ],
        sidebar: sidebarZh(),
        outline: { level: [2, 3], label: '本页目录' },
        docFooter: { prev: '上一页', next: '下一页' },
        editLink: {
          pattern: 'https://github.com/seesaw-earth/RodentFlow/edit/main/docs/:path',
          text: '在 GitHub 上编辑此页'
        },
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
          message: 'RodentFlow · iPhone、iPad 与 Mac · <a href="/RodentFlow/zh/source.html">源代码</a> · <a href="/RodentFlow/zh/privacy.html">隐私政策</a> · <a href="/RodentFlow/zh/support.html">支持</a> · <a href="/RodentFlow/zh/legal.html">法律与声明</a>',
          copyright: '© 2026 Ziqing Shi'
        }
      }
    }
  }
})
