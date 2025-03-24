let AudioRecorder = {
  mounted() {
    console.log("AudioRecorder Hook Mounted");

    this.el.addEventListener("click", async () => {
      try {
        if (!this.mediaRecorder) {
          const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

          this.mediaRecorder = new MediaRecorder(stream);
          this.audioChunks = [];

          this.mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
              this.audioChunks.push(event.data);
            }
          };

          this.mediaRecorder.onstop = () => {
            let audioBlob = new Blob(this.audioChunks, { type: "audio/wav" });
            let audioUrl = URL.createObjectURL(audioBlob);
            this.pushEvent("audio_recorded", { url: audioUrl });

            let audio = new Audio(audioUrl);
            audio.play();
          };

          this.audioChunks = [];
          this.mediaRecorder.start();
          console.log("Recording started...");
        } else {
          this.mediaRecorder.stop();
          this.mediaRecorder = null;
          console.log("Recording stopped.");
        }
      } catch (error) {
        console.error("Microphone access error:", error);
      }
    });
  }
};

export default AudioRecorder;
