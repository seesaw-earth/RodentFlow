import { h } from 'vue'
import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import LangSwitch from './LangSwitch.vue'
import './custom.css'

// The home pages (/RodentFlow/ and /RodentFlow/zh/) are standalone HTML files in docs/public,
// not VitePress pages. Open them with a normal page load instead of the client-side router,
// which would otherwise show "page not found".
function isHome(href: string, base: string): boolean {
  const path = new URL(href, window.location.href).pathname
  return [base, `${base}index.html`, `${base}zh/`, `${base}zh/index.html`].includes(path)
}

export default {
  extends: DefaultTheme,
  // English / 中文 link in the top bar on phones and tablets (see LangSwitch.vue).
  Layout: () => h(DefaultTheme.Layout, null, { 'nav-bar-content-after': () => h(LangSwitch) }),
  enhanceApp({ router, siteData }) {
    if (typeof window === 'undefined') return
    const previous = router.onBeforeRouteChange
    router.onBeforeRouteChange = (to) => {
      if (isHome(to, siteData.value.base)) {
        window.location.href = to
        return false
      }
      return previous?.(to)
    }
  }
} satisfies Theme
