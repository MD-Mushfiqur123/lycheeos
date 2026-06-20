/* cde/compositor/main.c */
#include <stdlib.h>
#include <wlr/backend.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_layer_shell_v1.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_scene.h>
#include <wlr/types/wlr_xwayland.h>

struct cde_server {
    struct wl_display *display;
    struct wlr_backend *backend;
    struct wlr_renderer *renderer;
    struct wlr_allocator *allocator;
    struct wlr_scene *scene;
    struct wlr_output_layout *output_layout;
    struct wlr_xdg_shell *xdg_shell;
    // struct wlr_layer_shell_v1 *layer_shell;
    struct wlr_xwayland *xwayland;
    
    struct wl_list outputs;
    struct wl_list views;
    struct wl_list workspaces;
    
    struct wl_listener new_xdg_surface;
};

static void server_new_xdg_surface(struct wl_listener *listener, void *data) {
    // Scaffold: Handle new XDG surface events (open windows)
}

int main(int argc, char *argv[]) {
    struct cde_server server = {0};
    
    server.display = wl_display_create();
    server.backend = wlr_backend_autocreate(wl_display_get_event_loop(server.display), NULL);
    
    if (!server.backend) {
        return 1;
    }

    server.renderer = wlr_renderer_autocreate(server.backend);
    wlr_renderer_init_wl_display(server.renderer, server.display);
    server.allocator = wlr_allocator_autocreate(server.backend, server.renderer);
    server.scene = wlr_scene_create();
    server.output_layout = wlr_output_layout_create(server.display);
    
    /* XDG shell (modern apps) */
    server.xdg_shell = wlr_xdg_shell_create(server.display, 6);
    server.new_xdg_surface.notify = server_new_xdg_surface;
    wl_signal_add(&server.xdg_shell->events.new_toplevel, &server.new_xdg_surface);
    
    /* XWayland (X11 compatibility) */
    server.xwayland = wlr_xwayland_create(server.display, wlr_compositor_create(server.display, server.renderer), false);
    
    const char *socket = wl_display_add_socket_auto(server.display);
    if (!socket) {
        return 1;
    }
    
    setenv("WAYLAND_DISPLAY", socket, 1);
    if (server.xwayland) {
        setenv("DISPLAY", server.xwayland->display_name, 1);
    }
    
    if (!wlr_backend_start(server.backend)) {
        return 1;
    }
    
    wl_display_run(server.display);
    wl_display_destroy_clients(server.display);
    wl_display_destroy(server.display);
    return 0;
}
