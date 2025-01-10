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
        // Browsers have a default behavior for dragged files:
        // trying to open the file in the browser or download it.
        // This default behavior prevents our own drop handlers from working.
        // Therefore, we need to first "disable" this default behavior
        // by adding listeners at the document level.
        document.addEventListener('dragover', (e) => {
          e.preventDefault();
          e.stopPropagation();
        }, false);

        document.addEventListener('drop', (e) => {
          e.preventDefault();
          e.stopPropagation();
        }, false);

        // Handler to toggle between file and folder selection
        this.handleEvent("switch-mode", () => {
          const input = this.el.querySelector('input[type="file"]');
          const activeButton = this.el.querySelector('button:focus');

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

        // Setting up specific handlers for our drop zone
        const dropZone = this.el;

        // Adds visual feedback when the file enters the drop area
        dropZone.addEventListener('dragenter', (e) => {
          e.preventDefault();
          e.stopPropagation();
          dropZone.classList.add('dragover');
        }, false);

        // Maintains visual feedback while the file is over the area
        dropZone.addEventListener('dragover', (e) => {
          e.preventDefault();
          e.stopPropagation();
          e.dataTransfer.dropEffect = 'copy';
          dropZone.classList.add('dragover');
        }, false);

        // Removes visual feedback when the file leaves the area
        dropZone.addEventListener('dragleave', (e) => {
          e.preventDefault();
          e.stopPropagation();
          dropZone.classList.remove('dragover');
        }, false);

        // Main handler for when files are dropped in the area
        dropZone.addEventListener('drop', async (e) => {
          console.log("Drop event triggered");
          e.preventDefault();
          e.stopPropagation();
          dropZone.classList.remove('dragover');

          const items = [...e.dataTransfer.items];
          console.log("Dropped items:", items);
          const files = [];

          // Process each item dropped in the area
          for (const item of items) {
            if (item.kind === 'file') {
              const entry = item.webkitGetAsEntry() || item.getAsEntry();
              if (entry) {
                if (entry.isDirectory) {
                  // If it's a directory, process recursively
                  await this.processDirectory(entry, files);
                } else if (entry.isFile) {
                  // If it's a file, check if it's PDF and add it
                  const file = await this.getFileFromEntry(entry);
                  if (file.name.toLowerCase().endsWith('.pdf')) {
                    file.relativePath = '';
                    files.push(file);
                  }
                }
              }
            }
          }

          // If PDF files were found, prepare for upload
          if (files.length > 0) {
            const input = this.el.querySelector('input[type="file"]');
            const dt = new DataTransfer();
            files.forEach(file => {
              // Create a new File with the necessary properties
              const newFile = new File([file], file.name, {
                type: file.type,
                lastModified: file.lastModified
              });
              // Add the relative path that will be used by the server
              Object.defineProperty(newFile, 'webkitRelativePath', {
                value: file.relativePath + file.name,
                writable: false
              });
              dt.items.add(newFile);
            });
            // Update the input's files and trigger the change event
            input.files = dt.files;
            input.dispatchEvent(new Event('change', { bubbles: true }));
          }
        }, false);
      },

      // Recursive function to process directories
      async processDirectory(dirEntry, files, path = '') {
        const entries = await this.readEntriesPromise(dirEntry);

        for (const entry of entries) {
          if (entry.isDirectory) {
            // If it's a directory, process recursively maintaining the path
            await this.processDirectory(entry, files, `${path}${entry.name}/`);
          } else if (entry.isFile) {
            const file = await this.getFileFromEntry(entry);
            if (file.name.toLowerCase().endsWith('.pdf')) {
              // Store the relative path to maintain the structure
              file.relativePath = path;
              files.push(file);
            }
          }
        }
      },

      // Converts the FileSystem callback API to Promises
      // This allows us to use async/await and have cleaner, more readable code
      // Instead of nested callbacks, we can write linear code
      readEntriesPromise(dirEntry) {
        return new Promise((resolve, reject) => {
          const reader = dirEntry.createReader();
          reader.readEntries(resolve, reject);
        });
      },

      // Similar to readEntriesPromise, converts the file API
      // from callbacks to Promises, allowing the use of async/await
      // and better error handling with try/catch
      getFileFromEntry(fileEntry) {
        return new Promise((resolve, reject) => {
          fileEntry.file(resolve, reject);
        });
      }
    },

    SlidingPanel: {
      mounted() {
        this.el.addEventListener('transitionend', () => {
          if (!this.el.classList.contains('translate-x-0')) {
            this.el.classList.add('hidden')
          }
        })
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

