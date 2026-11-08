<script setup lang="ts">
// A card at the top of the sidebar on every manual page that points to the task library.
import { computed } from 'vue'
import { useData, withBase } from 'vitepress'

const { lang, page } = useData()
const zh = computed(() => lang.value.startsWith('zh'))
const onTasks = computed(() => /^(zh\/)?tasks\//.test(page.value.relativePath) || /^(zh\/)?archive\//.test(page.value.relativePath))
const href = computed(() => withBase(zh.value ? '/zh/tasks/' : '/tasks/'))
const thumbs = computed(() =>
  ['elevated-plus-maze', 'three-chamber', 'water-maze', 'y-maze'].map((s) =>
    withBase(`/img/tasks/thumbs/${s}.${zh.value ? 'zh' : 'en'}.png`)
  )
)
</script>

<template>
  <a v-if="!onTasks" class="rf-promo" :href="href">
    <span class="rf-promo-thumbs"><img v-for="t in thumbs" :key="t" :src="t" alt="" loading="lazy" /></span>
    <strong>{{ zh ? '27 个实验范式 →' : '27 tasks →' }}</strong>
    <span>{{ zh ? '每个测试的设计、指标定义、模拟示例与文献' : 'Design, measures, a simulated example and references for every test' }}</span>
  </a>
</template>
