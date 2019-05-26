npm run build
cd dist
git init
git checkout --orphan gh-pages
git add -A
git commit -m "deploy"
git remote add origin https://github.com/tensojka/caffeine-tracker
git push origin gh-pages --force
