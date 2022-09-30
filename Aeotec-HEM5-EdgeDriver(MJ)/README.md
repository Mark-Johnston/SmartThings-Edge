This community written Smartthings EDGE driver is for the Aeotec Home Energy Meter Gen 5
It can be installed via the channel invitation at https://bestow-regional.api.smartthings.com/invite/o3jV3EPkmDMV

This was written because the stock driver was missing all of the positives that were available on the groovy platform thanks to https://github.com/ClassicGOD/SmartThingsPublic/tree/master/devicetypes/classicgod/aeotec-hem-gen5.src

ClassicGOD had done such a great job that when I bought the 3-clamp version in April knowing Groovy was being sunset, I thought i would try to write my first EDGE driver.

Note, that while I work in IT, I am not a developer and have never even seen LUA, let alone try to develop it.

This was developed with inspiration from the following areas:
- ClassicGOD Groovy implementation at https://github.com/ClassicGOD/SmartThingsPublic/tree/master/devicetypes/classicgod/aeotec-hem-gen5.src
- https://community.smartthings.com/t/new-smartthings-app-removed-ability-to-reset-power-and-kwh-on-energy-meters/210712/2
- Aeotec user guide at https://aeotec.freshdesk.com/support/solutions/articles/6000161943-home-energy-meter-gen5-user-guide-
- Aeotec details of the specific parameters https://aeotec.freshdesk.com/support/solutions/articles/6000191986-hem-gen5-parameter-101-103-and-111-113-use-
- Of course, the community is fab too https://community.smartthings.com/t/tutorial-creating-drivers-for-z-wave-devices-with-smartthings-edge/229503

This was written by me, for me, but if this works for the community, then glad to be of service. I have the 3 clamp version, one clamp on my ASHP, one clamp on the Solar inverter, and one clamp reporting everything else. This was done so I could have automations like "if the solar is generating more than 800w, then turn on the ASHP", and "if the car is plugged in while solar is generating, turn off the ASHP" - essentially giving me better control of how I use the energy in my home.

This is my first edge driver, so if there are improvements, please feel free to issue pull requests.
