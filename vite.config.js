import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    outDir: "public/builds",
    manifest: true,
    rollupOptions: {
      input: "app/assets/main.js",
    },
    copyPublicDir: false
  }
});
