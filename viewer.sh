##!/usr/bin/bash

# use nullglob in case there are no matching files
shopt -s nullglob

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




    
    # Return the results (or the default if querying didn't work)
    return
}


display_image() {
  clear
  if [ $h -eq 0 ]; then 
    convert "${images[$show_counter]}" sixel:-
  else
    #get width and height of image
    wx=$(identify -format "%w" "${images[$show_counter]}")
    hx=$(identify -format "%h" "${images[$show_counter]}")
    # set the border so that 
    # convert "${images[$show_counter]}" sixel:-
    convert "${images[$show_counter]}" -resize ${w}x${h} -background black -gravity center -extent ${w}x${h} sixel:-
    # convert "${images[$show_counter]}"  -bordercolor black -border $(((w-wx)/2))x$(((h-hx)/2)) sixel:-
  fi
  # cat "${images[$show_counter]}"
  # echo -ne "'q' to quit, 'n' for next, 'p' for previous"
}

getwindowsize
while true; do
  # get a list of sixel images in the HOME/.cache/matplotlib directory
  images=($( ls -t $HOME/.cache/matplotlib/*.png ))
  if [ ${#images[@]} -ne $num_images ]; then
    num_images=${#images[@]}
    show_counter=0
    display_image
  fi
  read -rsn1 -t 1 input
  if [ "$input" = "q" ]; then
    break
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
done
tput cnorm
echo
