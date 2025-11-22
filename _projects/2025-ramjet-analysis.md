---
layout: project
title: Ramjet Thermodynamic Analysis
description: Thermodynamics analysis project of device
technologies: [SolidWorks, Machining]
image: /assets/images/ramjet-diagram.jpg
---

A ramjet is a type of jet engine designed for high supersonic speeds. Similar to a subsonic turbojet, ramjets include a conbustor driven by a Brayton Cycle, followed by a nozzle that accelerates air out of the engine and produces thrust. However, ramjets differ from turbojets in that they do not include a compressor, nor a turbine to drive it, to compress inlet air. Instead, inlet air is compressed by a diffuser, taking advantage of the ram effect and the shockwave created by the engine hitting air at supersonic speeds to slow down and increase the pressure of inlet air. The drawback of this is that ramjets cannot operate nearly as efficiently at lower, subsonic speeds, like those present of takeoff and landing. Aircraft or missiles that use a ramjet engine must first be accelerated to supersonic speeds by a rocket or other propulsion system. 

![Ramjet qualitative diagram]({{ "/assets/images/diffuser.jpeg" | relative_url }}){: .inline-image-r style="width: 400px"}
Unlike more typical jet engines, turbojets or turbofans, ramjet engines do not use a compressor to slow incoming air down to speeds needed for combustion. Instead, in a diffuser, air moving a high velocities crashes into the engine, slowing down below Mach 1, and increasing in pressure. This diffuser essentially converts kinetic energy of inlet air into greater enthalpy and higher pressure. 

The now compressed air reaches the combustor at subsonic speeds after exiting the diffuser. Here, a small amount of fuel is burned to increase the temperature of the air. The mass flow of fuel per time into the combustor is much smaller than that of the air. From the NASA Glenn Research Center page on ramjet thrust, around 100 lbs/s of air enters the combustor compared to 2 lbs/s of fuel in a typical ramjet ([NASA GRC Ramjet Thrust](https://www.grc.nasa.gov/www/k-12/airplane/ramth.html)). The ramjet combustion cycle has some similarities to a Brayton cylce. In both, air is compressed in some way, then enters a combuster where burning fuel increases its temperature, and finally exits in some sort of exhaust. These are both open cycles, but differ in the way they compress inlet air, and in their exhaust mechanism and purpose. 


Finally, the hot, high pressure air reaches a converging-diverging nozzle. This accelerates the air to supersonic speeds greater than the air's inlet speed. This creates thrust, which we can model with the thrust equation `F_{thrust} = (\frac{dm}{dt} \cdot v_e) - (\frac{dm}{dt} \cdot v_i) + (p_e - p_i) \cdot A_e` . $7 + 7$ $`7 + 7`$ 7 + 7 $$7 + 7$$ $7 + 7$
$`\sqrt{3x-1}+(1+x)^2`$


Section 1: Diffuser and shockwave and ram effect

Section 2: Combustion and Brayton Cycle

Section 3: Nozzle, specifically convergent divergent nozzles

Section 4: Performance, efficiency, temperature, and comparison to other types of engines

Section 5: Drawbacks and difficulties of ramjets


Talk about the Blackbird turbofan ramjet thingy, possibly the X-43, though this is a scramjet drone

Ramjets are generally the most fuel efficient between Mach 3 and 5. 


Hi there hello. We are gonna analyze a ramjet under mass, energy, and entropy balances using a control volume approach. 