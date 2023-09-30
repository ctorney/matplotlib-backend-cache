##!/usr/bin/bash

# use nullglob in case there are no matching files
shopt -u nullglob

# create a variable to hold the number of images
num_images=-1
show_counter=0

tput civis

getwindowsize() {
  # return the width and height of the pane if tmux is running
  # if not in tmux return 0,0
  if [ -n "$TMUX" ]; then
    w=$(tmux display-message -p '#{pane_width}')  
    wc=$(tmux display-message -p '#{window_cell_width}')
    h=$(tmux display-message -p '#{pane_height}') 
    hc=$(tmux display-message -p '#{window_cell_height}')
    w=$((w*wc))
    h=$(((h)*hc))
  else    
    w=0
    h=0
  fi   
  

  # If the width is 0, then we're not in tmux, so get the size of the terminal
  if [ $w -eq 0 ]; then
    # tput cols returns the width of the terminal
    w=$(tput cols)
    # tput lines returns the height of the terminal
    h=$(tput lines)
  fi

  return
}


display_image() {
  # if the num_images is 0, do nothing
  if [ $num_images -eq 0 ]; then
    return
  fi
  clear
  if [ $h -eq 0 ]; then 
    convert "${images[$show_counter]}" sixel:-
  else
    #get width and height of image
    convert "${images[$show_counter]}" -resize ${w}x${h} -background black -gravity center -extent ${w}x${h} sixel:-
  fi
}

getwindowsize
echo "Press q to quit, n for next image, p for previous image, cc to clear cache"
sleep 2

while true; do
  read -rsn1 -t 1 input
  if [ "$input" = "q" ]; then
    break
  fi
  
  if find $HOME/.cache/matplotlib/ -mindepth 1 -maxdepth 1 -name *.png | read; then
    images=($( ls -t $HOME/.cache/matplotlib/*.png ))
    # print out the image file names
    if [ ${#images[@]} -ne $num_images ]; then
      num_images=${#images[@]}
      show_counter=0
      display_image
    fi
    if [ "$input" = "n" ]; then
      let show_counter+=1
      if [ $show_counter -ge $num_images ]; then
        show_counter=0
      fi
      getwindowsize
      display_image
    fi
    if [ "$input" = "p" ]; then
      let show_counter-=1
      if [ $show_counter -lt 0 ]; then
        show_counter=$((num_images - 1))
      fi
      getwindowsize
      display_image
    fi
    if [ "$input" = "c" ]; then
      read -rsn1 -t 1 input
      if [ "$input" = "c" ]; then
        rm $HOME/.cache/matplotlib/*.png
        num_images=-1
        show_counter=0
      fi
    fi 
  fi
done
tput cnorm
echo
