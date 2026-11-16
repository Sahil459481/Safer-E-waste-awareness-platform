import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static',
  trailingSlash: 'always',
  security: {
    checkOrigin: true,
  },
  vite: {
    server: {
      proxy: {
        '/api': {
          target: 'https://ezfnunyfoxlkatgickrk.supabase.co',
          changeOrigin: true,
          secure: true,
          rewrite: (path) => path.replace(/^\/api\/facilities/, '/functions/v1/facility-search'),
        },
      },
    },
  },
});
