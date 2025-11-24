---
layout: project
title: Ramjet Thermodynamic Analysis
description: Thermodynamics analysis project of device
technologies: []
image: /assets/images/ramjet-diagram.jpg
---

A ramjet is a type of jet engine designed for high supersonic speeds. Similar to a subsonic turbojet, ramjets include a conbustor driven by a Brayton Cycle, followed by a nozzle that accelerates air out of the engine and produces thrust. However, ramjets differ from turbojets in that they do not include a compressor, nor a turbine to drive it, to compress inlet air. Instead, inlet air is compressed by a diffuser, taking advantage of the ram effect and the shockwave created by the engine hitting air at supersonic speeds to slow down and increase the pressure of inlet air. The drawback of this is that ramjets cannot operate nearly as efficiently at lower, subsonic speeds, like those present of takeoff and landing. Aircraft or missiles that use a ramjet engine must first be accelerated to supersonic speeds by a rocket or other propulsion system. 

### Ramjet Components
![Diffuser qualitative diagram]({{ "/assets/images/diffuser.jpeg" | relative_url }}){: .inline-image-r style="width: 450px"}
Unlike more typical jet engines, turbojets or turbofans, ramjet engines do not use a compressor to slow incoming air down to speeds needed for combustion. Instead, in the diffuser, supersonic air crashes into and enters, creating a series of oblique shockwaves that terminate at a normal shockwaves perpendicular to the inside surface of the diffuser. Across the normal shockwave is an abrupt increase in pressure and drop to subsonic velocity of the air. This however, is an irreversible process. In essence, the diffuser converts high kinetic energy of inlet air into greater enthalpy and higher pressure. 

The now compressed air reaches the combustor at subsonic speeds after exiting the diffuser. Here, a small amount of fuel is burned to increase the temperature of the air. The mass flow of fuel per time into the combustor is much smaller than that of the air. From the NASA Glenn Research Center page on ramjet thrust, around 100 lbs/s of air enters the combustor compared to 2 lbs/s of fuel in a typical ramjet ([NASA GRC Ramjet Thrust](https://www.grc.nasa.gov/www/k-12/airplane/ramth.html)). The ramjet combustion cycle has some similarities to a Brayton cylce. In both, air is compressed in some way, then enters a combuster where burning fuel increases its temperature, and finally exits in some sort of exhaust. These are both open cycles, but differ in the way they compress inlet air, and in their exhaust mechanism and purpose. 

![Nozzle qualitative diagram]({{ "/assets/images/cv-nozzle.jpeg" | relative_url }}){: .inline-image-l style="width: 350px"}
Finally, the hot, high pressure air reaches a converging-diverging nozzle, where it is accelerated above air's inlet speed. In the first part of the CD-nozzle, the cross sectional area decreases, and air velocity increases to maintain constant mass flow rate. If the air traveling through a CD nozzle has sufficient pressure and mass flow rate, as it does in supersonic operation of a ramjet, air reaches the speed of sound at the nozzle's throat, where area is lowest. The CD nozzle then increases in area, and the air, now moving at Mach 1, expands quickly and velocity rises supersonically above the original inlet speed. This is accompanied by a decrease in pressure. The increase in exit velocity above inlet velocity creates thrust, which we can model with the thrust equation.
![Thrust Equation]({{ "/assets/images/thrust-eqn.jpeg" | relative_url }}){: .inline-image-r style="width: 300px"}



### Modeling an Ideal Ramjet
We seek to thermodynamically analyze a ramjet in "ideal" conditions. To do this, we need to make some modeling choices for the ramjet engine as a whole, and each of its 3 components. First, we will model a ramjet as a control volume. This is an open system, as air is not recyled back into the system after going through the engine. We assume the ramjet is operating at steady state for this analysis, and that there is no change in potential energy of fluid flow in the ramjet engine. Finally, we make the assumption that air is an ideal gas with constant specific heats. A ramjet will be operated in the atmosphere at pressures likely below sea level atmospheric pressure and at temperatures far from air the critical points of the gasses that mostly make up air, so this is a reasonable assumption.

![Diffuser system diagram]({{ "/assets/images/diagram-diff.jpeg" | relative_url }}){: .inline-image-r style="width: 300px"}
Next, we have decided to model that in an ideal ramjet, air flows through the diffuser isentropically. This means we consider it adiabaticly, and disregard the irreversibilites and entropy generation caused by the shockwaves and the drop below the speed of sound. There is also no mechanism for a work transfer in nor out in the diffuser.

![Heat Exchanger]({{ "/assets/images/heat-exchanger.jpeg" | relative_url }}){: .inline-image-l style="width: 250px"}
In both a Brayton Cycle combustor and in a ramjet combustor, ideally air is heated up at constant pressure. We saw the mass flow of fuel into the combustor is much smaller than the mass flow of air in, and we do not know much about the state of entering fuel. Because of this, we choose to model the combustor as a heat exhanger that raises the temperature of the air. This allows us to disregard entropy generation from fuel and air mixing as well. A further simplifying assumption we will make for our ideal ramjet cycle is that it is well insulated from the outside enviornment, and does not reject any heat via convection to the atmosphere. 

![Nozzle System Diagram]({{ "/assets/images/nozzle-diagram.jpeg" | relative_url }}){: .inline-image-r style="width: 300px"}
Finally, in an ideal converging-diverging nozzle, air flows through isentropically as well. We treat it adiabatically and having no work transfer, and disregard any irreversibilities stemming from how air reaches Mach 1 in the throat and expands supersonically in the diverging section. 

Our ramjet system as a whole we model below:
![Diffuser system diagram]({{ "/assets/images/system.jpeg" | relative_url }}){: .inline-image-l style="width: 500px"}
