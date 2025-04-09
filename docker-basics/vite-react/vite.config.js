import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  // to enable HMR when this dir is mounted on a container
  server:{
    host:true,  // important !! without it, the dev server only listens to localhost IP
    port:3000
  }
})
