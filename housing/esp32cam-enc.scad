// esp32cam-enc.scad
// A pan/tilt mounting box for esp32-cam crafted in openscad for
// a very cool wireless esp32 video/still camera board that only costs around $5.
// The enclosure can be printed for about $0.60 in filament.
// The camera board and lens are held securely in a recess in the top case and
// are secured when the bottom half is pressed on.
// The lens is recessed to help eliminate glare and maybe prevent some lens damage.
// This version has no hole for the power cord as you may want to use everything from
// a USB connector, a 2.1mm dc socket or a hardwired cable to provide 5V
// to the board. A hole would be easy to add in the "module bottom()".
//
// by L Glaister VE7IT  17 Dec 2019
//
// If you use the sd card slot, you may want to enable supports for printing
// to get a cleaner slot. (slot needs to be enabled in "module camera()")
// an additional slot would have to be added to "module bottom()" if you want access
// to the card from outside the enclosure. I did not add this as the camera is 
// just used to stream video/stills to a recording server running zone minder.
// I was more worried about keeping the weather and bugs out of the camera enclosure.
// The enclosure is not waterproof, but should survive if keep out of the direct rain.
// I will mount mine under the eaves in 3 places to monitor the yard around the house.
// The enclosure was keep small and compact to make it less conspicuous. Printing
// in a color that matches you soffits will help it blend in.
// All 3 parts needed for the case print nicely together on a small 3d printer.
//
$fn = 64;

pcbx = 40.1+0.2;  // pcb long dimension
pcby = 27.2+0.2;  // pcb shorter dimension
pcbz = 1.05+0.2;  // pcb thickness

lensd = 7.1+0.5;  // lens dia
lensx = 29.5;
lensy = pcby /2.0;
lensz = 5.4;  // bottom of pcb to base of lens
lensh = 2.25+0.2; // height of lens + extra
cambx = 8.65+0.4; // clearance needed for body of camera
camby = 8.65+0.4;

boxwall = 5.0;    // wall thickness
toph   = 10.0;    // thickness of top box

pinh = 9.0;   // how much space needed for pins on rear of pcb

// generate a shape model of the camera upper surface and pcb
// this gets subtracted from a solid base to form a pocket that
// holds the pcb and camera in place.
module camera()
{
  hull()
  {
    translate([lensx-cambx/2,lensy-camby/2,0]) cube([cambx,camby,lensz]);   // camera body
    translate([16.2,1,0]) cube([20,2,3.5]);                                 // room for pins
    translate([16.2,24.0,0]) cube([20,2,3.5]);                              // room for pins
    translate([25.2,pcby/2-7.5,0]) cube([15.0,15.0,3.0]);                   // sdcard slot
    translate([9.3,0.4,0]) cube([7,3.5,2.0]);                               // led + xsistor
    translate([8,4.8,0]) cube([9.4,16.5,3.5]);                              // cam connector
    translate([17.3,3.5,0]) cube([7.75,19.75,3.1]);                         // cable + parts
    translate([10.0,22.3,0]) cube([6.5,3.5,2.2]);                           // reg + parts
  }
  cube([pcbx,pcby,pcbz]);
  //translate([1,pcby-4,pcbz]) rotate([0,0,-90]) linear_extrude(0.5) text("ESP32-CAM",2.5);
  translate([lensx,lensy,lensz]) cylinder(h=lensh, d=lensd);  // lens
  translate([lensx,lensy,lensz+lensh]) cylinder(h=6, d1=lensd, d2=3*lensd); // lens flare
  // below is optional... only needed if you need to put an sd card in the camera
  //translate([40.0,pcby/2-7.5,pcbz]) cube([15.0,15.0,3.0-pcbz]);             // sdcard slot access
}

module boxjoint()
{
  difference()
  {
    cube([pcbx+boxwall,pcby+boxwall,toph/2]);    
    translate([boxwall/4,boxwall/4,0]) cube([pcbx+boxwall/2,pcby+boxwall/2,toph]);
  }
}

module bracket()
{
  hole=4.0;   // mounting hole size
  clrn = 0.1; // clearance for pivot
  difference() 
  {
    union()
    {
      cube([pcbx+boxwall+clrn*2,boxwall,pinh]);
      translate([-boxwall,0,0]) cube([boxwall,pcby+6,pinh]);
      translate([pcbx+boxwall+clrn*2,0,0]) cube([boxwall,pcby+6,pinh]);
      // 2 pins to engage box
      translate([0,pcby-pinh/2+6,pinh/2]) rotate([0,90,0])             cylinder(h=boxwall/3-clrn,d1=pinh-clrn,d2=pinh*0.75-clrn);
      translate([pcbx+boxwall+clrn*2,pcby-pinh/2+6,pinh/2]) rotate([0,-90,0]) cylinder(h=boxwall/3-clrn,d1=pinh-clrn,d2=pinh*0.75-clrn);
      // a reinforcing boss on mounting screw
      translate([(pcbx+boxwall+clrn)/2,-1.2,pinh/2]) rotate([-90,0,0])cylinder(d=pinh,h=boxwall*1.3);

    }
    // cutout mounting hole for #6 screw
    translate([(pcbx+boxwall)/2,-boxwall*5,pinh/2]) rotate([-90,0,0])cylinder(d=hole,h=boxwall*10);
  } 
}

module top()
{
  difference()
  {
    cube([pcbx+boxwall,pcby+boxwall,toph]);
    union()
    {
      translate([boxwall/2,boxwall/2,0]) camera();  // carve out camera
      boxjoint();                                   // carve off the box overlap
    }
  }
}

module bottom()
{
  both = pinh + boxwall/2 + toph/2; // total ht of bottom box
  clr = 0.1;    // a little fudge to make boxes mate
  difference()
  {
    cube([pcbx+boxwall,pcby+boxwall,both]);
    union()
    {
      // cutout for pcb connections
      translate([boxwall/2,boxwall/2,boxwall/2]) cube([pcbx,pcby,both]);
      // cutout for overlap
      translate([boxwall/4-clr/2,boxwall/4-clr/2,both-toph/2]) cube([pcbx+boxwall/2+clr,pcby+boxwall/2+clr,toph/2]);
      //tapered plug cutouts for mounting bracket
      translate([0,(pcby+boxwall)/2,pinh/2+2]) rotate([0,90,0])             cylinder(h=boxwall/3,d1=pinh,d2=pinh*0.75);
      translate([pcbx+boxwall,(pcby+boxwall)/2,pinh/2+2]) rotate([0,-90,0]) cylinder(h=boxwall/3,d1=pinh,d2=pinh*0.75);
      // sign work by embossing inside of bottom of box (adds compute time, but saves some filament!
      translate([3,20,boxwall/2-0.5]) rotate([0,0,0]) linear_extrude(0.5) text("ESP32-CAM",5);
      translate([8,10,boxwall/2-0.5]) rotate([0,0,0]) linear_extrude(0.5) text("by VE7IT",5);
    }
  }
  // add some posts in the corners to hold pcb in top of case when mated
  translate([boxwall/2,boxwall/2,boxwall/2]) cylinder(h=pinh,d=boxwall);
  translate([boxwall/2,boxwall/2+pcby,boxwall/2]) cylinder(h=pinh,d=boxwall);
  translate([boxwall/2+pcbx,boxwall/2,boxwall/2]) cylinder(h=pinh,d=boxwall);
  translate([boxwall/2+pcbx,boxwall/2+pcby,boxwall/2]) cylinder(h=pinh,d=boxwall);
}


//======================= set all the pieces up for printing ==============================
bottom();
translate([0,-5,toph]) rotate([180,0,0])  top(); // flip top over and move it for printing
translate([-boxwall,-(pcbx+boxwall)/2,0]) rotate([0,0,90]) bracket();
//bracket();