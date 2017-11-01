cat maize_v3.longest.aa.fa | grep ">" |  sed -e 's/ .*//g' -e 's/_P[0-9]\+//g' -e 's/FGP/FG/g' | tr -d '>' > maize_v3.refset.txt
