<template>
<section class="section">
  <div class="container content">
    <h1 class="title is-2">Caffeine tracker</h1>
    <nav class="level" v-if="lastKnownAmount != null">
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">Current level</p>
          <p class="title">{{Math.round(amountAtUnixtime(Date.now()))}} mg</p>
        </div>
      </div>
      <div class="level-item has-text-centered">
        <div>
          <p class="heading">In three hours</p>
          <p class="title">{{ Math.round(amountAtUnixtime(Date.now() + 3*3600000) )}} mg</p>
        </div>
      </div>
      <div v-if="(new Date()).getHours() < 20.5" class="level-item has-text-centered">
        <div>
          <p class="heading">At 23:00</p>
          <p class="title" v-bind:class="{ insignificant: (amountAtHoursOfDay(23) < 20)}">{{ amountAtHoursOfDay(23) }} mg</p>
        </div>
      </div>
      <div v-if="(new Date()).getHours() > 19" class="level-item has-text-centered">
        <div>
          <p class="heading">At 7:00</p>
          <p class="title">{{ amountAtHoursOfDay(7) }} mg</p>
        </div>
      </div>
    </nav>
    <button class="button is-fullwidth is-medium is-primary" @click="inputModalActive = true">Record a drink</button>
    <b-modal :active.sync="inputModalActive">
      <div class="card">
        <div class="card-content">
          <div class="content">
            <div class="field">
              <label class="label">Time</label>
              <div class="control">
                <b-timepicker inline is-medium v-model="time"></b-timepicker>
              </div>
            </div>
            <div class="field">
              <label class="label">Amount of caffeine in miligrams</label>
              <div class="control">
                <b-numberinput v-model="amount" min="0" step="5" placeholder="miligrams"></b-numberinput>
              </div>
            </div>
            <div class="field">
              <div class="control">
                <b-button type="is-primary" @click="saveIngestion">Save</b-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </b-modal>
    <br>
      <article v-if="currentAmount > 400" class="is-danger message">
          <div class="message-header">
            <p>You overdid it.</p>
          </div>
          <div class="message-body">
            Doses higher than 400 mg cause overdose symptoms like nausea, vomiting, jitters, restlessness and nervousness. Your sleep will be severely impaired.
          </div>
      </article>
    <hr>
    <p>
      <a href="https://github.com/tensojka/caffeine-tracker">source code</a>
    </p>
  </div>
</section>
</template>

<script>
export default {
  name: "app",
  data: () => {
    return {
      lastKnownAmount: null,
      lastKnownAmountTime: null,
      inputModalActive: false,
      time: new Date(),
      amount: 0
    };
  },
  methods: {
    amountAtUnixtime: function(date) {
      if(typeof date != "number"){
        throw "Date passed to amountAtUnixtime MUST BE number"
      }
      const halfLife = 18000000; // all durations are in ms // 5 hours approx
      var res =
        this.lastKnownAmount *
        Math.pow(0.5, (date - this.lastKnownAmountTime) / halfLife);
      return res;
    },
    amountAtHoursOfDay: function(hoursOfDay) {
      var curr = new Date();
      if (curr.getHours() > hoursOfDay) {
        return Math.round(
          this.amountAtUnixtime(
            new Date(
              curr.getFullYear(),
              curr.getMonth(),
              curr.getDate() + 1,
              hoursOfDay
            ).valueOf()
          )
        );
      } else {
        return Math.round(
          this.amountAtUnixtime(
            new Date(
              curr.getFullYear(),
              curr.getMonth(),
              curr.getDate(),
              hoursOfDay
            ).valueOf()
          )
        );
      }
    },
    computeLastKnown: function(){
      this.lastKnownAmount = null
      this.lastKnownAmountTime = null
      if(window.localStorage.getItem("ingestions") != null){
        var ingestions = JSON.parse(window.localStorage.getItem("ingestions"))
        for (var i = 0; i < ingestions.length; i++) {
          if(this.lastKnownAmountTime != null){
            this.lastKnownAmount = this.amountAtUnixtime(new Date(this.lastKnownAmountTime).valueOf()) + ingestions[i].v
          }else{
            this.lastKnownAmount = ingestions[i].v
          }
          this.lastKnownAmountTime = new Date(ingestions[i].t)
        }
      }
    },
    saveIngestion: function(){
      var ingestionsJson = window.localStorage.getItem("ingestions")
      var ingestions
      if (ingestionsJson == null){
        ingestions = []
      }else{
        ingestions = JSON.parse(ingestionsJson)
      }
      ingestions.push({t: this.time, v: this.amount})
      window.localStorage.setItem("ingestions", JSON.stringify(ingestions))
      this.computeLastKnown()
      this.inputModalActive = false
    }
  },
  computed: {
    currentAmount: function(){
      return this.amountAtUnixtime(new Date().valueOf())
    }
  },
  mounted(){
    this.computeLastKnown()
  }
};
</script>

<style>
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 60px;
}
.insignificant {
  color: hsl(0, 0%, 71%);
}
</style>
