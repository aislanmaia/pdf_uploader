// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import FlashHook from './hooks/flash_hook'

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    Flash: FlashHook,
    AutoClearFlash: {
      mounted() {
        const element = this.el;
        element.classList.remove('slide-in');
        element.classList.add('slide-out');

        let ignoredIDs = ["client-error", "server-error"];
        if (ignoredIDs.includes(this.el.id)) return;

        let hideElementAfter = 5000; // ms
        let clearFlashAfter = hideElementAfter + 500; // ms

        // first hide the element
        setTimeout(() => {
          this.el.style.opacity = 0;
        }, hideElementAfter);

        // then clear the flash
        setTimeout(() => {
          this.pushEvent("lv:clear-flash");
        }, clearFlashAfter);
      },
    },

    UploadHandler: {
      mounted() {
        this.handleEvent("switch-mode", () => {
          const input = this.el.querySelector('input[type="file"]');
          const activeButton = this.el.querySelector('button:focus');
          console.log("activeButton", activeButton)
          if (activeButton) {
            const mode = activeButton.dataset.mode;
            if (mode === 'folder') {
              input.setAttribute('webkitdirectory', '');
              input.setAttribute('directory', '');
            } else {
              input.removeAttribute('webkitdirectory');
              input.removeAttribute('directory');
            }
            setTimeout(() => input.click(), 100);
          }
        });
      }
    }
  }
})

// document.addEventListener('phx:update', () => {
//   console.log("phx:update")
//   const container = document.getElementById('upload-container');
//   console.log("container", container)
//   if (container) {

//     const input = container.querySelector('input[type="file"]');
//     const activeButton = container.querySelector('button:focus');
//     console.log("activeButton", activeButton)
//     if (activeButton) {
//       const mode = activeButton.dataset.mode;
//       console.log("mode", mode)
//       if (mode === 'folder') {
//         input.setAttribute('webkitdirectory', '');
//         input.setAttribute('directory', '');
//       } else {
//         input.removeAttribute('webkitdirectory');
//         input.removeAttribute('directory');
//       }
//       setTimeout(() => input.click(), 100);
//     }
//   }

// });

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

