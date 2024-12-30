let FlashHook = {
  mounted() {
    console.log("window.liveSocket", window.liveSocket)

    this.timer = setTimeout(() => {
      const element = this.el;
      element.classList.remove('slide-in');
      element.classList.add('slide-out');
      
      // Aguarda a animação terminar antes de limpar o flash
      element.addEventListener('transitionend', () => {
        // Verifica se o elemento ainda existe e se o LiveView está conectado
        if (this.el && window.liveSocket && window.liveSocket.isConnected()) {
          try {
            console.log("window.liveSocket", window.liveSocket.isConnected())
            this.pushEvent("lv:clear-flash", { key: this.el.dataset.kind });
          } catch (e) {
            // Se falhar ao enviar o evento, apenas remove o elemento
            this.el.remove();
          }
        }
      });
    }, 5000);
  },
  destroyed() {
    clearTimeout(this.timer);
  }
}

export default FlashHook;