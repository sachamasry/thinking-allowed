let AudioRecorder = {
  mounted() {
    console.log("AudioRecorder Hook Mounted");

    this.mediaRecorder = null;
    this.audioChunks = [];

    this.el.addEventListener("click", () => {
      if (!this.mediaRecorder) {
        navigator.mediaDevices.getUserMedia({ audio: true })
          .then((stream) => {
            this.mediaRecorder = new MediaRecorder(stream);

            this.mediaRecorder.ondataavailable = (event) => {
              if (event.data.size > 0) {
                this.audioChunks.push(event.data);
              }
            };

            this.mediaRecorder.onstop = () => {
              let audioBlob = new Blob(this.audioChunks, { type: "audio/wav" });
              let audioUrl = URL.createObjectURL(audioBlob);

              this.pushEvent("audio_recorded", { url: audioUrl });

              // Play the recorded audio
              let audio = new Audio(audioUrl);
              audio.play();
            };

            this.audioChunks = [];
            this.mediaRecorder.start();
            console.log("Recording started...");
          })
          .catch((error) => {
            console.error("Error accessing microphone:", error);
          });
      } else {
        this.mediaRecorder.stop();
        this.mediaRecorder = null;
        console.log("Recording stopped.");
      }
    });
  }
};

export default AudioRecorder;
