<script setup lang="ts">
// A visible English / 中文 link in the top bar on phones and tablets. VitePress itself shows its
// language menu in the bar only on wide screens (1280 px and up); below that it is hidden inside
// the menu, so this link takes its place there. It opens the same page in the other language.
import { computed } from 'vue'
import { useData, withBase } from 'vitepress'

const { page, localeIndex } = useData()
const isZh = computed(() => localeIndex.value === 'zh')

const href = computed(() => {
  if (page.value.isNotFound) return withBase(isZh.value ? '/' : '/zh/')
  let rel = page.value.relativePath
    .replace(/(^|\/)index\.md$/, '$1')
    .replace(/\.md$/, '.html')
  rel = isZh.value ? rel.replace(/^zh\//, '') : `zh/${rel}`
  return withBase(`/${rel}`)
})
</script>

<template>
  <a
    class="rf-lang-switch"
    :href="href"
    :lang="isZh ? 'en' : 'zh-CN'"
    :hreflang="isZh ? 'en' : 'zh-CN'"
    :aria-label="isZh ? 'English version of this page' : '本页中文版'"
  >{{ isZh ? 'EN' : '中文' }}</a>
</template>

<style scoped>
.rf-lang-switch {
  display: flex;
  align-items: center;
  height: var(--vp-nav-height);
  padding: 0 10px;
  font-size: 14px;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  white-space: nowrap;
}

.rf-lang-switch:hover {
  color: var(--vp-c-brand-2);
}

@media (min-width: 1280px) {
  .rf-lang-switch {
    display: none;
  }
}
</style>
