include <./polyround.scad>
include <./constants.scad>
include <./helpers.scad>

module mobo_mount(size="matx", with_grid_filling=true, mount_support_thickness = 5) {
    screw_hole_diameter = 3.96;
    screw_hole_support_diameter = screw_hole_diameter + 3;

    module draw_atx_screws(d = screw_hole_diameter) {        
        
        function atx_screws_pos(height=atx_height)=[
            [height - 6.35,                   10.16 + 12.7], [height - 6.35,                   10.16 + 154.94], [height - 6.35,                   10.16 + 227.33], 
            [height - 6.35 - 157.48,          10.16],        [height - 6.35 - 157.48,          10.16 + 154.94], [height - 6.35 - 157.48,          10.16 + 227.33],
            [height - 6.35 - 157.48 - 124.46, 10.16],        [height - 6.35 - 157.48 - 124.46, 10.16 + 154.94], [height - 6.35 - 157.48 - 124.46, 10.16 + 227.33],
        ];

        function matx_screws_pos(height=matx_height)=[
            [height - 6.35,                   10.16 + 12.7], [height - 6.35,                   10.16 + 154.94], [height - 6.35,                   10.16 + 227.33], 
            [height - 6.35 - 157.48,          10.16],        [height - 6.35 - 157.48,          10.16 + 154.94], [height - 6.35 - 157.48,          10.16 + 227.33],
            [height - 6.35 - 157.48 - 45.72, 10.16],
                                                             [height - 6.35 - 157.48 - 45.72 - 20.32, 10.16 + 154.94]
        ];

        function itx_screws_pos(height=itx_height)=[
            [height - 6.35,                   10.16 + 12.7], [height - 6.35,                   10.16 + 154.94], 
            [height - 6.35 - 157.48,          10.16],        [height - 6.35 - 157.48,          10.16 + 154.94], 
        ];

        module draw(screws) {
            for (pos = screws) {
                translate([pos[1], pos[0]]) circle(d = d, $fn = global_fn);
            }
        }
        
        if (size == "atx") {
            draw(atx_screws_pos());
        } else if (size == "matx") {
            draw(matx_screws_pos());
        } else {
            draw(itx_screws_pos());
        }
    }

    function square_points(w, h, r)=[
        [0, 0, r],
        [w, 0, r],
        [w, h, r],
        [0, h, r],
    ];

    module btf_cutouts() {
        btf_cutouts = [
            [20, 280, 60, 15],  // ATX 24-pin power cutout (right side)
            [220, 280, 60, 15], // Additional cutout (top)
            [20, 30, 1]    // CPU power cutout (top-left corner)
        ];
    }
    
    module draw(height, width, iter=42, mount_thickness) {
        
        module draw_plate(grid_spacing = 5) {

            if (with_grid_filling) {
                translate([0,0, -mount_thickness]) linear_extrude(mount_thickness) shell2d(-mount_thickness) {
                    polygon(polyRound(square_points(width, height, corner_round), global_fn));
                    difference() {
                        gridpattern(memberW = mount_thickness, sqW = mount_thickness * grid_spacing, iter = iter, r = corner_round);
                        draw_atx_screws();
                    }
                    
                    difference() {
                        draw_atx_screws(screw_hole_support_diameter + mount_thickness * 5);
                        draw_atx_screws();
                    }
                }
            } else {
                translate([0,0, -mount_thickness]) linear_extrude(mount_thickness) {
                    difference() {
                        polygon(polyRound(square_points(width, height, corner_round), global_fn));
                        draw_atx_screws();
                    }
                }
            }
        }
        
        union() {
            draw_plate();
            
            translate([0,0, -0.1]) linear_extrude(mount_support_thickness + 0.1) difference() {
                draw_atx_screws(screw_hole_support_diameter);
                draw_atx_screws();
            }
        }
    }
    
    if (size == "atx") {
        draw(atx_height, atx_width, 42, 4.5);
    } else if (size == "matx") {
        draw(matx_height, atx_width, 38, 3.5);
    } else {
        draw(itx_height, itx_width, 26, 3);
    }
}

mobo_mount();
