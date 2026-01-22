Thoughts about the volume issue [Failed to turn `` into a value of type f64](https://github.com/elkowar/eww/issues/787) and my adoption of eww.
I followed the link to the user's eww configuration (https://github.com/HardoMX/eww/tree/master) and discovered it hasn't been updated in three years.
This made me realize there aren't many eww configuration repositories on GitHub, and most of them haven't been updated for years.
Searching through his repository, I found in his [hypr configuration](https://github.com/HardoMX/hypr/blob/3cd672b8df798f7c11cb9efad94846e59b980614/startup.conf#L14):
> (# exec-once = $HOME/.config/eww/launch_bar.sh # Change away from EWW in progress)
He has switched to waybar instead.
This led me to reconsider: Why does eww have so many GitHub stars, yet people seem to be abandoning it?
* **Why so many stars:** eww's appearance is visually impressive, creating a great first impression for newcomers.
* **Why people leave:** The documentation is lacking, and there are persistent bugs that go unfixed.
So my conclusion is eww may not be a good choice for my desktop environment.
