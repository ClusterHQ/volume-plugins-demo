#  Remove directory directory
cd ~/dockercon-demo/volume-plugins-demo/
vagrant destroy -f
cd ~/
rm -rf  ~/dockercon-demo
rm ~/Downloads/ucp-bundle*

#Close safari and Terminal
pkill Safari
pkill Terminal

#Exit terminal
osascript -e 'tell application "Terminal" to quit' &
exit
