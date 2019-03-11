import { PolymerElement, html } from '@polymer/polymer/polymer-element.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/app-route/app-route.js';


import './shared-styles.js';

class LogOut extends PolymerElement {
    static get template() {
        return html`
      <style include="shared-styles">
        :host {
          display: block;
          margin: 0;
          padding: 10px;
        }
        
        paper-button {
          background-color: #9aae04;
        }
        
      </style>
      
    
    <app-location route="{{route}}"></app-location>
    <iron-localstorage name="user-storage" value="{{storedUser}}"></iron-localstorage>
    <paper-button raised on-tap="logout">Log Out [[[storedUser.name]]]</paper-button>
    `;
    }

    static get properties() {
        return {
            storedUser: Object
        }
    }

    logout() {
        this.storedUser = null;
        location.reload(); // because meh
    }
}

window.customElements.define('log-out', LogOut);


