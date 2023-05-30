turtles-own [
  schoolmates        ;; agentset of nearby turtles, within visual field
  zor-mates          ;; agentsent of turtles within zone of repulsion
  nearest-neighbor   ;; closest one of our schoolmates
]

to setup
  clear-all

    ;; Create water
  ask patches [
    set pcolor sky + 2
  ]

  create-turtles population
    [ set color magenta + random 6  ;; random shades look nice
      set size 2  ;; easier to see
      ;; set shape "fish"
      setxy random-xcor random-ycor
      set schoolmates no-turtles ]

;  set model-version "schooling"
;  set repulsion-radius 1
;  set visual-radius 10
;  set max-turn-angle 4
;  set turn-noise 8


  reset-ticks
end

to go
  ask turtles [ school ]
  ;; the following line is used to make the turtles
  ;; animate more smoothly.
  repeat 5 [ ask turtles [ fd 0.2 ] display ]
  ;; for greater efficiency, at the expense of smooth
  ;; animation, substitute the following line instead:
  ;;   ask turtles [ fd 1 ]
  tick
end

to school  ;; turtle procedure
  find-schoolmates
  if any? schoolmates
  [
    find-schoolmates-zor
    ifelse any? zor-mates  ;; if any neighbors within zone of repulsion, separate
      [ separate ]
      [ align ]            ;; otherwise align with neighbors
  ]
end

to find-schoolmates-zor  ;; turtle procedure, repulsion zone neighbors
  set zor-mates schoolmates in-radius repulsion-radius
end


to find-schoolmates  ;; turtle procedure
   set schoolmates other turtles in-radius visual-radius
end

to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of schoolmates [distance myself]
end

;;; REPULSION

to separate  ;; turtle procedure
  ifelse model-version = "noisy-schooling"
  [ turn-away (average-heading-towards-zormates + (random-normal 0 turn-noise))  max-turn-angle ]
  [ turn-away average-heading-towards-zormates max-turn-angle]
end

to-report average-heading-towards-zormates  ;; turtle procedure
  ;; "towards myself" gives us the heading from the other turtle
  ;; to me, but we want the heading from me to the other turtle,
  ;; so we add 180
  let x-component mean [sin (towards myself + 180)] of zor-mates
  let y-component mean [cos (towards myself + 180)] of zor-mates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; ALIGN (turn toward average of neighbor headings)

to align  ;; turtle procedure
  ifelse model-version = "noisy-schooling"
  [ turn-towards (average-schoolmate-heading + (random-normal 0 turn-noise)) max-turn-angle ]
  [ turn-towards average-schoolmate-heading max-turn-angle ]
end

to-report average-schoolmate-heading  ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  let x-component sum [dx] of schoolmates
  let y-component sum [dy] of schoolmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; HELPER PROCEDURES

to turn-towards [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end

to turn-away [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end

;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [turn max-turn]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ]
    ]
    [ rt turn ]
end

to-report group-polarization  ;; turtle procedure
  ;; The group polarization is defined as the
  ;; absolute value of the mean individual headings

  let x-component sum [dx] of turtles
  let y-component sum [dy] of turtles
  ifelse x-component = 0 and y-component = 0
    [ report 0 ]
    [ report (sqrt (x-component ^ 2 + y-component ^ 2)) / count turtles]
end

;to-report average-group-heading  ;; turtle procedure
;  ;; Input your code below to compute the mean group heading
;  let x-component ;code goes here
;  let y-component ;code goes here
;  ifelse x-component = 0 and y-component = 0
;    [ report 0 ]
;    [ report ;code goes here ]
;end

; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
280
10
827
558
-1
-1
7.0
1
10
1
1
1
0
1
1
1
-38
38
-38
38
1
1
1
ticks
30.0

BUTTON
39
102
116
135
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
122
102
203
135
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
9
60
232
93
population
population
10
300.0
50.0
10.0
1
NIL
HORIZONTAL

SLIDER
4
238
229
271
max-turn-angle
max-turn-angle
1
20
6.0
0.5
1
degrees
HORIZONTAL

SLIDER
5
197
228
230
visual-radius
visual-radius
1
15
6.0
0.5
1
patches
HORIZONTAL

SLIDER
4
157
227
190
repulsion-radius
repulsion-radius
0.5
3
1.0
0.5
1
patches
HORIZONTAL

SLIDER
28
289
200
322
turn-noise
turn-noise
3
12
8.0
1
1
degrees
HORIZONTAL

CHOOSER
39
10
189
55
model-version
model-version
"schooling" "noisy-schooling"
0

MONITOR
64
341
151
386
polarization
(min [group-polarization] of turtles)
3
1
11

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to mimic the schooling behavior of fishes. 
The fish schools that emerge in this model are not created or led in any way
by a leader fish. Instead, each fish is following its own behavioral rules, from
which schooling emerges. 

Note: This model is adapted from the flocking model. The behavioral rules are a 
slight modification of the model by Couzin et al. (Collective Memory and Spatial Sorting in Animal Groups, 2002)


## HOW IT WORKS

The fish follow two rules: "repulsion" and "alignment"

"Repulsion" means that a fish will turn away from fish which get too close.
Each fish desires its own personal space. 

"Alignment" means that a fish tends to turn so that it is moving in the same direction that nearby fishes are moving.

When neighboring fish are too close, the "repulsion" rule overrides the "alignment" rule, which is deactivated until there are no fish within the zone of repulsion.

The two rules affect only the fish's heading.  Each fish always moves forward at the same constant speed.

## HOW TO USE IT

First, determine the number of fish you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the fishes, and press GO to have them start swimming around.

The default settings for the sliders will produce reasonably good schooling behavior.  However, you can play with them to get variations:

REPULSION-RADIUS is the distance that each fish needs around it, its personal space.

VISUAL-RADIUS is the distance that each fish can sense neighbors around it.

The MAX-TURN-ANGLE slider controls the maximum angle a fish can turn.

The TURN-NOISE slider is used in conjuction with the "noisy-schooling" model version and controls the possible values of the error (noise) added to each fish's turns. 

## THINGS TO NOTICE

Central to the model is the observation that schools form without a leader.

In the "schooling" model version are no random numbers used, except to position the fishes initially.  The fluid, lifelike behavior of the fishes is produced entirely by deterministic rules.

In the "noisy-schooling" model version there are random numbers used. We add a little bit
of error to each fish's turn, which can be due to sensing or movement errors, for example. This version of the model is much more dynamic than the non-noisy version.

Notice that each school is dynamic.  A school, once together, is not guaranteed to keep all of its members, especially in the noisy-schooling version.  Why do you think this is?

After running the model for a while, all of the fishes have approximately the same heading.  Why?

Sometimes a fish breaks away from its school.  How does this happen?  You may need to slow down the model or run it step by step in order to observe this phenomenon.

## THINGS TO DO

Play with the sliders to see if you can get tighter schools, looser schools, fewer schools, more schools, more or less splitting and joining of schools, more or less rearranging of fishes within schools, etc.

Try to get the fish to align as quickly as possible, we can gauge the level of alignment with the polarization order parameter. 

You can model reduced visual sensing ability by decreasing the value of the visual-radius slider.

What happens when the repulsion radius is very high?

What is the effect of the max-turn-radius?

Will running the model for a long time produce a static school?  Or will the fishes never settle down to an unchanging formation? 

## LAB 8 TASKS (Biomechanics of Animal Interactions)

1. Generate a simulation in which there are distinct sub-groups or "shoals" that are schooling together (i.e., aligned and near one another).  
Save an image of the view with: File --> Export --> Export View

2. Create a monitor to keep track of the average group heading. (Use the polarization monitor and its associated reporter as a guide). 

3. Plot the polarization parameter. (You can use models from the Model Library as a guide for setting up a new plot).

4. Generate a simulation in which polarization reaches a value of 1 very quickly and another which takes much longer. Make a note of what parameter values were used to produce each of these two simulations and incude them in your submission.
Save each plot with: File --> Export --> Export Plot

5. Save the final Interface with: File --> Export --> Export Interface

You will submit the images corresponding to tasks 1, 4, and 5. 


## EXTENDING THE MODEL

Currently the fishes can "see" all around them.  What happens if fishes can only see in front of them?  The `in-cone` primitive can be used for this.

Can you get the fishes to swim around obstacles in the middle of the world?

What would happen if you gave the fishes different velocities?  For example, you could make the fish that are not near others swim faster to catch up to the school. 

Are there other interesting ways you can make the fishes different from each other?  There could be random variation in the population, or you could have distinct "species" of fishes.

## NETLOGO FEATURES

Notice the need for the `subtract-headings` primitive and special procedure for averaging groups of headings.  Just subtracting the numbers, or averaging the numbers, doesn't give you the results you'd expect, because of the discontinuity where headings wrap back to 0 once they reach 360.

## RELATED MODELS

* Moths
* Flocking Vee Formation
* Flocking - Alternative Visualizations

## CREDITS AND REFERENCES

This model is inspired by Iain Couzin's model of fish schooling. The algorithm I use here is not the same, but it is very similar. In this model, I have not included the three zones (repulsion, orientation, attraction) described in (Collective Memory and Spatial Sorting in Animal Groups, 2002).

I used the Flocking model from the Models Library as a guide for setting up this code. 

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Soto, A. (2023). NetLogo fish Schooling model. 
(Not submitted to model libary)

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 1998 2002 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
true
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
