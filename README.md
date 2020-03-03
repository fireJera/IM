# IM

merge git command

https://thoughts.t37.net/merging-2-different-git-repositories-without-losing-your-history-de7a06bba804

cd ../new-project
git remote add old-project ../old-project
git fetch old-project
git checkout -b feature/merge-old-project
git merge -S --allow-unrelated-histories old-project/master
git push origin feature/merge-old-project
git remote rm old-project

