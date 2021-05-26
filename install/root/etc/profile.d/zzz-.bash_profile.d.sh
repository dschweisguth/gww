for i in $HOME/.bash_profile.d/*.sh; do
  if [ -r "$i" ]; then
    . "$i"
  fi
done
