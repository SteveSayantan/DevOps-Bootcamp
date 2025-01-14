import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  // to enable HMR when this dir is mounted on a container
  server:{
    host:true,
    port:3000
  }
})
