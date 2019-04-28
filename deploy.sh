npm run build
cd dist
git checkout gh-pages
git add -A
git commit -m "deploy"
git push
