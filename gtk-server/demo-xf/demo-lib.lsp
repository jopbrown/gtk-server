#!/usr/bin/newlisp
#
# Demo with XForms
# Tested with GTK-server 2.1.2 compiled for XForms and newLisp 8.9.0
# ------------------------------------------------------------------

# Setup gtk-server
(import "libgtk-server.so" "xf")

# Optionally enable GTK logging
(xf "gtk_server_cfg log=/tmp/gtk-server.log")

(println (get-string (xf "gtk_server_version")))

# Connect to the GTK-server
(setq WINDOW (get-string (xf "fl_bgn_form FL_BORDER_BOX 320 240")))
(xf {fl_add_box FL_NO_BOX 160 40 0 0 "Do you want to Quit?"})

(setq YBUT (get-string (xf "fl_add_button FL_NORMAL_BUTTON 40 70 80 30 Yes")))
(xf (append "fl_set_object_color " YBUT " 2 3"))

(setq NBUT (get-string (xf "fl_add_button FL_NORMAL_BUTTON 200 70 80 30 No")))
(xf (append "fl_set_object_color " NBUT " 3 2"))

(xf {fl_add_text FL_NORMAL_TEXT 40 120 160 30 "Hello this is a demo"})

(setq INPUT (get-string (xf "fl_add_input FL_NORMAL_INPUT 70 160 130 30 Data:")))
(xf (append "fl_set_input " INPUT { "Enter your info here"}))

(xf "fl_end_form")
(xf (append "fl_show_form " WINDOW " FL_PLACE_CENTER FL_FULLBORDER Question"))

# Mainloop starts here
(set 'event 0)

(while (!= event "")

    (set 'event (get-string (xf (append "gtk_server_callback wait"))))

    (if (= event YBUT)(println "YES button clicked"))
    (if (= event NBUT)(println "NO button clicked"))
)

# Exit GTK-server
(xf "gtk_server_exit")

# Exit newLisp
(exit)
