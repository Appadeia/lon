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

using Lon.Configs;

namespace Lon.Views {

    /**
     * The {@code AppView} class.
     *
     * @since 1.0.0
     */
    public class WelcomeView : Gtk.Box {

        /**
         * Constructs a new {@code AppView} object.
         */
        public GWeather.LocationEntry entry;

        public WelcomeView () {
            var icon = new Gtk.Image.from_icon_name("mark-location-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            icon.pixel_size = 256;
            icon.margin_bottom = 32;

            var label = new Gtk.Label("sina lon seme?");
            label.get_style_context().add_class("title-1");
            label.margin_bottom = 18;

            entry = new GWeather.LocationEntry(null);
            entry.width_request = 400;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            box.add(icon);
            box.add(label);
            box.add(entry);

            box.expand = true;
            box.valign = Gtk.Align.CENTER;
            box.halign = Gtk.Align.CENTER;

            this.add(box);
        }
    }
    public class AppView : Gtk.Box {
        public GWeather.Location loc;
        public bool active;
        
        protected GWeather.Info info;
        protected bool polling = false;
        protected Gtk.Box box;

        protected Gtk.CssProvider provider;
        protected MainInfo main_info;
        protected InfoCards info_cards;

        public static string get_temp_name(double temp) {
            if (temp <= 0) {
                return "lete mute li lon";
            } else if (temp > 0 && temp < 10) {
                return "lete li lon";
            } else if (temp > 10 && temp < 20) {
                return "lete lili li lon";
            } else if (temp > 20 && temp < 25) {
                return "seli lili li lon";
            } else if (temp > 25 && temp < 30) {
                return "seli li lon";
            } else if (temp >= 30) {
                return "seli mute li lon";
            }
            return "invalid temp";
        }
        protected void set_window_colour(double temp) {       
            if (!active)
                return;
            if (temp <= 0) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/verycold.css");
            } else if (temp > 0 && temp < 10) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/cold.css");
            } else if (temp > 10 && temp < 20) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/mildcold.css");
            } else if (temp > 20 && temp < 25) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/mildhot.css");
            } else if (temp > 25 && temp < 30) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/hot.css");
            } else if (temp >= 30) {
                provider.load_from_resource ("/com/github/Appadeia/lon/css/veryhot.css");
            }
        }
        
        public void clear_window_colour() {
            try {
                provider.load_from_data("");
            } catch {
                return;
            }
        }
        public void start_polling() {
            this.info = new GWeather.Info(loc);
            this.info.enabled_providers = GWeather.Provider.YR_NO;
            this.info.updated.connect(() => {
                double temp = -1;
                var valid = this.info.get_value_apparent(GWeather.TemperatureUnit.CENTIGRADE, out temp);
                if (!valid) {
                    valid = this.info.get_forecast_list().nth_data(0).get_value_apparent(GWeather.TemperatureUnit.CENTIGRADE, out temp);
                }

                main_info.temp_label.set_text(get_temp_name(temp));
                this.set_window_colour(temp);
                main_info.weather_icon.icon_name = this.info.get_icon_name() + "-symbolic";
                if (info_cards == null) {
                    info_cards = new InfoCards(ref this.info);
                    box.add(info_cards);
                    info_cards.show_all();
                } else {
                    info_cards.hide();
                    box.remove(info_cards);
                    info_cards = null;
                    info_cards = new InfoCards(ref this.info);
                    box.add(info_cards);
                    info_cards.show_all();
                }
            });
            
            main_info.city_label.set_text(loc.get_city_name());
            main_info.country_label.set_text(loc.get_country_name());

            if (polling) {
                this.info.update();
                return;
            }
            
            this.info.update();
            GLib.Timeout.add_seconds(30, () => {
                this.info.update();
                return true;
            }, GLib.Priority.DEFAULT);
        }

        public AppView () {
            provider = new Gtk.CssProvider ();
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            box.expand = true;
            box.halign = Gtk.Align.CENTER;
            box.margin = 32;

            main_info = new MainInfo();

            var sep = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
            var kama = new Gtk.Label("tempo kama la...");
            kama.xalign = -1;
            kama.get_style_context().add_class("title-1");

            box.add(main_info);
            box.add(sep);
            box.add(kama);

            box.width_request = 500;

            this.add(box);
        }
    }
    public class MainInfo : Gtk.Bin {
        public Gtk.Label temp_label;
        public Gtk.Image weather_icon;
        public Gtk.Label city_label;
        public Gtk.Label country_label;

        public MainInfo() {
            temp_label = new Gtk.Label("o awen...");
            temp_label.get_style_context().add_class("title-1");
            temp_label.get_style_context().add_class("temperature");

            city_label = new Gtk.Label("");
            city_label.get_style_context().add_class("title-3");

            country_label = new Gtk.Label("");
            country_label.get_style_context().add_class("title-5");

            weather_icon = new Gtk.Image.from_icon_name("document-open-recent-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            weather_icon.set_pixel_size(128);

            var h_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 18);
            var h_box_left = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            var h_box_right = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            var h_box_right_top = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);

            h_box_right.homogeneous = true;

            h_box.add(h_box_left);
            h_box.add(h_box_right);

            h_box_left.add(weather_icon);
            
            h_box_right_top.add(city_label);
            h_box_right_top.add(country_label);
            h_box_right.add(h_box_right_top);
            h_box_right.add(temp_label);

            city_label.xalign = -1;
            country_label.xalign = -1;
            temp_label.xalign = -1;

            country_label.yalign = 1;
            temp_label.yalign = 1;

            this.add(h_box);
        }
    }
    public class InfoCards : Gtk.Bin {
        public InfoCards(ref GWeather.Info info) {
            print("info cards created\n");
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            this.add(box);
            if (info.get_forecast_list().length() == 0) {
                var label = new Gtk.Label("sona pi tenpo kama li lon ala");
                label.get_style_context().add_class("title-1");
                label.xalign = -1;
                box.add(label);
                return;
            }

            int i = 0;
            foreach (var item in info.get_forecast_list()) {
                if (i > 9)
                    break;
                if (item == info.get_forecast_list().nth_data(0))
                    continue;
                i++;
                if (!item.is_valid())
                    continue;
                double forecast_val;
                item.get_value_temp(GWeather.TemperatureUnit.CENTIGRADE, out forecast_val);

                var card = new InfoCard();
                card.temp_forecast.set_text(AppView.get_temp_name(forecast_val));
                box.add(card);

                long val;
                item.get_value_update(out val);
                var tz = new GLib.TimeZone(item.location.get_timezone().get_tzid());
                var time = new GLib.DateTime.from_unix_utc(val).to_timezone(tz);
                card.time.set_text(time.format("tenpo %H:%M"));
                card.icon.icon_name = info.get_symbolic_icon_name();
            }

        }
    }
    public class InfoCard : Gtk.Bin {
        public Gtk.Label temp_forecast;
        public Gtk.Label time;
        public Gtk.Image icon;

        public InfoCard() {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 16);
            temp_forecast = new Gtk.Label("");
            temp_forecast.get_style_context().add_class("title-2");
            time = new Gtk.Label("");
            box.add(time);
            box.add(temp_forecast);
            icon = new Gtk.Image.from_icon_name("ood", Gtk.IconSize.BUTTON);
            var spacer = new Gtk.Image();
            spacer.hexpand = true;
            box.add(spacer);
            box.add(icon);
            this.add(box);
        }
    }
}
