import { LightningElement,api } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import FullCalendarPlugin from "@salesforce/resourceUrl/FullCalendarResource";

export default class FullCalendarByLwc extends LightningElement {
isResourceLoaded = false;
@api calendarJson = [];
// Redercallback method will load FullCalendar Plugin Javascripts and CSS.
renderedCallback() {
    if (this.isResourceLoaded) {
        return;
    }

    this.isResourceLoaded = true;

    Promise.all([
        loadStyle(this, FullCalendarPlugin + "/packages/core/main.css"),
        loadScript(this, FullCalendarPlugin + "/packages/core/main.js"),
    ])
        .then(() => {
            Promise.all([
                loadStyle(this, FullCalendarPlugin + "/packages/daygrid/main.css"),
                loadScript(this, FullCalendarPlugin + "/packages/daygrid/main.js"),
            ])
                .then(() => {
                    Promise.all([
                        loadStyle(
                            this,
                            FullCalendarPlugin + "/packages/timegrid/main.css"
                        ),
                        loadScript(
                            this,
                            FullCalendarPlugin + "/packages/timegrid/main.js"
                        ),
                    ])
                        .then(() => {
                            this.initCalendar(this.calendarJson);
                        })
                        .catch((error) => {
                            console.error({
                                message: "Error occured loading daygrid",
                                error,
                            });
                        });
                })
                .catch((error) => {
                    console.error({ message: "Error occured loading timegrid", error });
                });
        })
        .catch((error) => {
            console.error({
                message: "Error occured on loading core files",
                error,
            });
        });
}

// initiate the Calendar in the DOM.
initCalendar(calendarJson) {
    console.log('eList',JSON.stringify(calendarJson));
    let self = this;
    const calendarEl = this.template.querySelector("div.fullcalendar");
    let calendar = new FullCalendar.Calendar(calendarEl, {
        plugins: ["timeGrid", "dayGrid"],
        defaultView: "dayGridMonth",
        height: "parent",
        header: {
            left: "prev, next",
            center: "title",
            right: "today timeGridDay, timeGridWeek, dayGridMonth",
        },
        events: calendarJson,
        eventTimeFormat: { 
            hour: '2-digit',
            minute: '2-digit',
            meridiem: 'long'
            },
        titleFormat: { month: "short", day: "numeric", year: "numeric" },
        
    });
    calendar.render();
}

}