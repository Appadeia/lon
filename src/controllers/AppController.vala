/*
* Created 2019  Carson Black <uhhadd@gmail.com>
* 
* This is free and unencumbered software released into the public domain.
* 
* Anyone is free to copy, modify, publish, use, compile, sell, or
* distribute this software, either in source code form or as a compiled
* binary, for any purpose, commercial or non-commercial, and by any
* means.
* 
* In jurisdictions that recognize copyright laws, the author or authors
* of this software dedicate any and all copyright interest in the
* software to the public domain. We make this dedication for the benefit
* of the public at large and to the detriment of our heirs and
* successors. We intend this dedication to be an overt act of
* relinquishment in perpetuity of all present and future rights to this
* software under copyright law.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
* 
* For more information, please refer to <http://unlicense.org>
*/

using Lon.Views;

namespace Lon.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 1.0.0
     */
    public class AppController {

        private Gtk.Application            application;
        private WelcomeView                welcome_view;
        private AppView                    app_view;
        private Lon.Window                 window { get; private set; default = null; }
        private Gtk.Stack                  stack;

        /**
         * Constructs a new {@code AppController} object.
         */
        public AppController (Gtk.Application application) {
            this.application = application;
            window = new Window (this.application);
            welcome_view = new WelcomeView();
            app_view = new AppView ();

            stack = new Gtk.Stack();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;

            stack.add_named(welcome_view, "welcome_view");
            stack.add_named(app_view, "app_view");

            welcome_view.entry.activate.connect(() => {
                if (welcome_view.entry.location != null) {
                    app_view.loc = welcome_view.entry.location;
                    app_view.start_polling();
                    stack.set_visible_child_name("app_view");
                    app_view.active = true;
                }
                window.lon.show();
                window.lon.clicked.connect(() => {
                    stack.set_visible_child_name("welcome_view");
                    app_view.active = false;
                    app_view.clear_window_colour();
                    window.lon.hide();
                });
            });

            window.add (stack);

            window.set_default_size (800, 640);
            this.application.add_window (window);

            Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);
            Gtk.Settings.get_default ().set ("gtk-theme-name", "Adwaita");
            Gtk.Settings.get_default ().set ("gtk-icon-theme-name", "Adwaita");
            Gtk.Settings.get_default ().set ("gtk-font-name", "Cantarell 11");
            Gtk.Settings.get_default ().set ("gtk-decoration-layout", ":close");
        }

        public void activate () {
            window.show_all ();
            app_view.activate ();
        }

        public void quit () {
            window.destroy ();
        }
    }
}
