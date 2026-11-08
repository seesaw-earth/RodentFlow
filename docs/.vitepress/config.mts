import { defineConfig, type DefaultTheme } from 'vitepress'

// Published at https://seesaw-earth.github.io/RodentFlow/ — every absolute link below is
// relative to this base. Change `base` if the repository is renamed.
// The home pages (/ and /zh/) are not VitePress pages: they are docs/public/index.html and
// docs/public/zh/index.html, a standalone showcase page with its own styles and script.
const base = '/RodentFlow/'

function sidebarEn(): DefaultTheme.SidebarItem[] {
  return [
    {
      text: 'Get started',
      items: [
        { text: 'What RodentFlow does', link: '/guide/introduction' },
        { text: 'iPhone, iPad and Mac', link: '/guide/editions' },
        { text: 'Quick start', link: '/guide/getting-started' },
        { text: 'Recording videos that track well', link: '/guide/recording' }
      ]
    },
    {
      text: 'Using RodentFlow',
      items: [
        { text: 'Analysing a video', link: '/guide/video-analysis' },
        { text: 'Results and exports', link: '/guide/results' },
        { text: 'Comparing groups', link: '/guide/groups' },
        { text: 'Manual entry & importing tables', link: '/guide/manual-and-import' }
      ]
    },
    {
      text: 'Tasks',
      items: [
          {
            text: 'All tasks',
            link: '/tasks/'
          },
          {
            text: 'Social behaviour',
            collapsed: true,
            items: [
              {
                text: 'Three-chamber sociability',
                link: '/tasks/three-chamber'
              },
              {
                text: 'Social interaction test (CSDS)',
                link: '/tasks/social-interaction'
              },
              {
                text: 'Dyadic social interaction',
                link: '/tasks/dyadic-social'
              },
              {
                text: 'Resident–intruder (aggression)',
                link: '/tasks/resident-intruder'
              }
            ]
          },
          {
            text: 'Navigation & neural recording',
            collapsed: true,
            items: [
              {
                text: 'Head direction',
                link: '/tasks/head-direction'
              },
              {
                text: 'Spatial exploration (place / grid cells)',
                link: '/tasks/spatial-exploration'
              }
            ]
          },
          {
            text: 'Anxiety & risk assessment',
            collapsed: true,
            items: [
              {
                text: 'Open field',
                link: '/tasks/open-field'
              },
              {
                text: 'Elevated plus maze',
                link: '/tasks/elevated-plus-maze'
              },
              {
                text: 'Elevated zero maze',
                link: '/tasks/elevated-zero-maze'
              },
              {
                text: 'Light–dark box',
                link: '/tasks/light-dark-box'
              },
              {
                text: 'Novelty-suppressed feeding',
                link: '/tasks/novelty-suppressed-feeding'
              },
              {
                text: 'Visual cliff',
                link: '/tasks/visual-cliff'
              },
              {
                text: 'Marble burying',
                link: '/tasks/marble-burying'
              }
            ]
          },
          {
            text: 'Learning, memory & fear',
            collapsed: true,
            items: [
              {
                text: 'Novel object recognition',
                link: '/tasks/novel-object-recognition'
              },
              {
                text: 'Barnes maze',
                link: '/tasks/barnes-maze'
              },
              {
                text: 'Morris water maze',
                link: '/tasks/water-maze'
              },
              {
                text: 'Passive avoidance (step-through)',
                link: '/tasks/passive-avoidance'
              },
              {
                text: 'Step-down inhibitory avoidance',
                link: '/tasks/step-down'
              },
              {
                text: 'Place preference (RTPP / CPP)',
                link: '/tasks/place-preference'
              },
              {
                text: 'Y-maze spontaneous alternation',
                link: '/tasks/y-maze'
              },
              {
                text: 'T-maze choice & VTE',
                link: '/tasks/t-maze'
              },
              {
                text: 'Fear conditioning',
                link: '/tasks/fear-conditioning'
              },
              {
                text: 'Looming threat escape',
                link: '/tasks/looming-escape'
              },
              {
                text: 'Platform-mediated avoidance',
                link: '/tasks/platform-avoidance'
              }
            ]
          },
          {
            text: 'Motor function & coping',
            collapsed: true,
            items: [
              {
                text: 'Rotation (unilateral lesion)',
                link: '/tasks/rotation'
              },
              {
                text: 'Tail suspension, multi-chamber',
                link: '/tasks/tail-suspension'
              }
            ]
          },
          {
            text: 'General',
            collapsed: true,
            items: [
              {
                text: 'Pose only',
                link: '/tasks/pose-only'
              }
            ]
          }
        ]
    },
    {
      text: 'Mac',
      items: [
        { text: 'RodentFlow on the Mac', link: '/mac/' },
        { text: 'Quick start on the Mac', link: '/mac/quick-start' },
        { text: 'The Mac workflow', link: '/mac/workflow' },
        { text: 'Mac exports', link: '/mac/exports' },
        { text: 'Keyboard shortcuts', link: '/mac/shortcuts' },
        { text: 'Phone to Mac sync', link: '/reference/sync' }
      ]
    },
    {
      text: 'How it works',
      items: [
        { text: 'How tracking works', link: '/principles/tracking' },
        { text: 'From tracks to measures', link: '/principles/metrics' },
        { text: 'Statistics', link: '/principles/statistics' },
        { text: 'Speed and accuracy', link: '/principles/performance' },
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
        { text: '5 · WhiteMousePose6', link: '/tutorials/white-mouse' },
        { text: '6 · MousePose6-DyadBW', link: '/tutorials/dyad-bw' },
        { text: 'How to cite', link: '/tutorials/citations' }
      ]
    },
    {
      text: 'Blog',
      items: [
        { text: 'All posts', link: '/blog/' },
        { text: 'Training on existing tracks', link: '/blog/training-on-existing-tracks' }
      ]
    },
    {
      text: 'Reference',
      items: [
        { text: 'Files and formats', link: '/reference/files' },
        { text: 'Where your data lives', link: '/reference/data-and-backups' },
        { text: 'FAQ', link: '/reference/faq' },
        { text: 'Further reading', link: '/reference/reading' },
        { text: 'Release notes', link: '/reference/changelog' },
        { text: 'Older versions', link: '/archive/' }
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

function sidebarZh(): DefaultTheme.SidebarItem[] {
  return [
    {
      text: '入门',
      items: [
        { text: 'RodentFlow 能做什么', link: '/zh/guide/introduction' },
        { text: 'iPhone、iPad 与 Mac', link: '/zh/guide/editions' },
        { text: '快速上手', link: '/zh/guide/getting-started' },
        { text: '怎样拍出好追踪的视频', link: '/zh/guide/recording' }
      ]
    },
    {
      text: '使用 RodentFlow',
      items: [
        { text: '分析一段视频', link: '/zh/guide/video-analysis' },
        { text: '结果与导出', link: '/zh/guide/results' },
        { text: '组间比较', link: '/zh/guide/groups' },
        { text: '手动录入与导入表格', link: '/zh/guide/manual-and-import' }
      ]
    },
    {
      text: '实验范式',
      items: [
          {
            text: '全部范式',
            link: '/zh/tasks/'
          },
          {
            text: '社交行为',
            collapsed: true,
            items: [
              {
                text: '三箱社交',
                link: '/zh/tasks/three-chamber'
              },
              {
                text: '社交回避测试',
                link: '/zh/tasks/social-interaction'
              },
              {
                text: '双鼠社交互动',
                link: '/zh/tasks/dyadic-social'
              },
              {
                text: '居住者–入侵者（攻击）',
                link: '/zh/tasks/resident-intruder'
              }
            ]
          },
          {
            text: '空间导航与神经记录',
            collapsed: true,
            items: [
              {
                text: '头朝向',
                link: '/zh/tasks/head-direction'
              },
              {
                text: '空间探索 · 位置细胞',
                link: '/zh/tasks/spatial-exploration'
              }
            ]
          },
          {
            text: '焦虑与风险评估',
            collapsed: true,
            items: [
              {
                text: '旷场',
                link: '/zh/tasks/open-field'
              },
              {
                text: '高架十字迷宫',
                link: '/zh/tasks/elevated-plus-maze'
              },
              {
                text: '高架零迷宫',
                link: '/zh/tasks/elevated-zero-maze'
              },
              {
                text: '明暗箱',
                link: '/zh/tasks/light-dark-box'
              },
              {
                text: '新奇抑制摄食',
                link: '/zh/tasks/novelty-suppressed-feeding'
              },
              {
                text: '视觉悬崖',
                link: '/zh/tasks/visual-cliff'
              },
              {
                text: '埋珠实验',
                link: '/zh/tasks/marble-burying'
              }
            ]
          },
          {
            text: '学习、记忆与恐惧',
            collapsed: true,
            items: [
              {
                text: '新物体识别',
                link: '/zh/tasks/novel-object-recognition'
              },
              {
                text: 'Barnes 迷宫',
                link: '/zh/tasks/barnes-maze'
              },
              {
                text: 'Morris 水迷宫',
                link: '/zh/tasks/water-maze'
              },
              {
                text: '被动回避（穿梭箱）',
                link: '/zh/tasks/passive-avoidance'
              },
              {
                text: 'Step-down 抑制性回避',
                link: '/zh/tasks/step-down'
              },
              {
                text: '位置偏好（RTPP / CPP）',
                link: '/zh/tasks/place-preference'
              },
              {
                text: 'Y 迷宫自发交替',
                link: '/zh/tasks/y-maze'
              },
              {
                text: 'T 迷宫 · VTE',
                link: '/zh/tasks/t-maze'
              },
              {
                text: '恐惧条件化',
                link: '/zh/tasks/fear-conditioning'
              },
              {
                text: 'Looming 逃跑',
                link: '/zh/tasks/looming-escape'
              },
              {
                text: '平台介导回避',
                link: '/zh/tasks/platform-avoidance'
              }
            ]
          },
          {
            text: '运动功能与应对',
            collapsed: true,
            items: [
              {
                text: '旋转行为',
                link: '/zh/tasks/rotation'
              },
              {
                text: '多格悬尾',
                link: '/zh/tasks/tail-suspension'
              }
            ]
          },
          {
            text: '通用',
            collapsed: true,
            items: [
              {
                text: '仅导出姿态',
                link: '/zh/tasks/pose-only'
              }
            ]
          }
        ]
    },
    {
      text: 'Mac',
      items: [
        { text: 'Mac 上的 RodentFlow', link: '/zh/mac/' },
        { text: 'Mac 快速上手', link: '/zh/mac/quick-start' },
        { text: 'Mac 工作流程', link: '/zh/mac/workflow' },
        { text: 'Mac 导出', link: '/zh/mac/exports' },
        { text: '键盘快捷键', link: '/zh/mac/shortcuts' },
        { text: '手机到 Mac 同步', link: '/zh/reference/sync' }
      ]
    },
    {
      text: '原理',
      items: [
        { text: '追踪原理', link: '/zh/principles/tracking' },
        { text: '从轨迹到指标', link: '/zh/principles/metrics' },
        { text: '统计方法', link: '/zh/principles/statistics' },
        { text: '速度与精度', link: '/zh/principles/performance' },
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
        { text: '5 · WhiteMousePose6 白鼠', link: '/zh/tutorials/white-mouse' },
        { text: '6 · MousePose6-DyadBW 一黑一白', link: '/zh/tutorials/dyad-bw' },
        { text: '如何引用', link: '/zh/tutorials/citations' }
      ]
    },
    {
      text: '博客',
      items: [
        { text: '全部文章', link: '/zh/blog/' },
        { text: '用已有轨迹训练小模型', link: '/zh/blog/training-on-existing-tracks' }
      ]
    },
    {
      text: '参考',
      items: [
        { text: '文件与格式', link: '/zh/reference/files' },
        { text: '数据存放位置与备份', link: '/zh/reference/data-and-backups' },
        { text: '常见问题', link: '/zh/reference/faq' },
        { text: '延伸阅读', link: '/zh/reference/reading' },
        { text: '版本说明', link: '/zh/reference/changelog' },
        { text: '旧版本', link: '/zh/archive/' }
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

// Older pages (RodentFlow 1.x for iPhone, Mac 0.7) keep their own short sidebar.
function sidebarArchive(zh: boolean): DefaultTheme.SidebarItem[] {
  const p = zh ? '/zh/archive' : '/archive'
  return [
    { text: zh ? '← RodentFlow 2.1 手册' : '← RodentFlow 2.1 manual', link: zh ? '/zh/guide/introduction' : '/guide/introduction' },
    { text: zh ? '旧版本' : 'Older versions', link: `${p}/` }
  ]
}

export default defineConfig({
  base,
  title: 'RodentFlow',
  description: 'Mouse behaviour tracking and analysis on iPhone, iPad and Mac — RodentFlow 2.1 manual',
  lastUpdated: false,
  cleanUrls: false,
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: `${base}favicon-64.png` }],
    ['link', { rel: 'apple-touch-icon', href: `${base}apple-touch-icon.png` }],
    ['meta', { name: 'theme-color', content: '#1f86c9' }],
    ['meta', { property: 'og:type', content: 'website' }]
  ],
  // Link previews (LinkedIn, Slack, iMessage…): title, description, URL and image per page.
  // A page can set its own preview image with `image:` in its frontmatter (a path under docs/public).
  transformHead({ pageData, siteData }) {
    const site = `https://seesaw-earth.github.io${base}`
    const fm = pageData.frontmatter
    const title = fm.title ?? pageData.title
    const description = fm.description || pageData.description || siteData.description
    const path = pageData.relativePath.replace(/(^|\/)index\.md$/, '$1').replace(/\.md$/, '.html')
    const image = fm.image ? site + String(fm.image).replace(/^\//, '') : `${site}og-default.png`
    return [
      ['meta', { property: 'og:title', content: title ? `${title} | RodentFlow` : 'RodentFlow' }],
      ['meta', { property: 'og:description', content: description }],
      ['meta', { property: 'og:url', content: site + path }],
      ['meta', { property: 'og:image', content: image }],
      ['meta', { name: 'twitter:card', content: 'summary_large_image' }]
    ]
  },
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
      description: 'Mouse behaviour tracking and analysis on iPhone, iPad and Mac — RodentFlow 2.1 manual',
      themeConfig: {
        nav: [
          {
            text: 'Manual',
            activeMatch: '^/(guide|mac|principles|reference)/',
            items: [
              { text: 'Get started', link: '/guide/introduction' },
              { text: 'Analysing a video', link: '/guide/video-analysis' },
              { text: 'Comparing groups', link: '/guide/groups' },
              { text: 'Mac', link: '/mac/' },
              { text: 'How it works', link: '/principles/tracking' },
              { text: 'Speed and accuracy', link: '/principles/performance' },
              { text: 'Reference', link: '/reference/files' }
            ]
          },
          { text: 'Tasks', link: '/tasks/', activeMatch: '^/tasks/' },
          { text: 'Models & tutorials', link: '/models', activeMatch: '^/(models|tutorials/)' },
          { text: 'Blog', link: '/blog/', activeMatch: '^/blog/' },
          { text: 'Source code', link: '/source' },
          { text: 'Support', link: '/support' }
        ],
        sidebar: { '/archive/': sidebarArchive(false), '/': sidebarEn() },
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
            activeMatch: '^/zh/(guide|mac|principles|reference)/',
            items: [
              { text: '入门', link: '/zh/guide/introduction' },
              { text: '分析一段视频', link: '/zh/guide/video-analysis' },
              { text: '组间比较', link: '/zh/guide/groups' },
              { text: 'Mac', link: '/zh/mac/' },
              { text: '原理', link: '/zh/principles/tracking' },
              { text: '速度与精度', link: '/zh/principles/performance' },
              { text: '参考', link: '/zh/reference/files' }
            ]
          },
          { text: '实验范式', link: '/zh/tasks/', activeMatch: '^/zh/tasks/' },
          { text: '模型与教程', link: '/zh/models', activeMatch: '^/zh/(models|tutorials/)' },
          { text: '博客', link: '/zh/blog/', activeMatch: '^/zh/blog/' },
          { text: '源代码', link: '/zh/source' },
          { text: '支持', link: '/zh/support' }
        ],
        sidebar: { '/zh/archive/': sidebarArchive(true), '/zh/': sidebarZh() },
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
