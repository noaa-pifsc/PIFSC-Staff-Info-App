// Initialize Tippy.js for all elements with the 'person-tooltip-trigger' class
const personnelTooltips = tippy('.person-tooltip-trigger', {
    interactive: true, // Allows the user to click and select content within the tooltip
    allowHTML: true,   // Allows rendering of HTML content inside the tooltip
    placement: 'auto', // Automatically determines the best placement (top, bottom, left, right) to keep the tooltip on-screen
    theme: 'custom-tooltip', // Applies the custom CSS theme defined for the tooltips
    // This function dynamically gets the content for the tooltip based on the triggered element's data-tooltip-id
    content(reference) {
        const person_id = reference.getAttribute('data-tooltip-id'); // Gets the unique ID from the HTML element
        // Finds the corresponding person's data in the pre-loaded personnelData array
        const person = personnelData.find(p => p.PERS_ID === person_id);
        // Generates and returns the HTML string for the tooltip's content
        return generateTooltipContent(person);
    },
    // Sets the delay for showing and hiding the tooltip in milliseconds.
    // set 100ms delay before showing, and 300ms delay before hiding.
    delay: [100, 300],
    // Defines how the tooltip is triggered and dismissed.
    // 'mouseenter': Shows on mouse hover.
    // 'focus': Shows when the element is focused (e.g., via keyboard navigation).
    // 'click': Shows on click, and will usually persist until clicked outside or the trigger is clicked again.
    trigger: 'mouseenter focus click',

    // Specifies where the tooltip's DOM element should be appended.
    // Appending to document.body (rather than the trigger's parent) helps prevent layout shifts in complex table structures.
    appendTo: () => document.body,
});


// Function that generates the tooltip HTML for a given person in the organization so it can be displayed
function generateTooltipContent(person) {
    // If no person object is provided (e.g., data not found), return a default message
    if (!person) {
        return '<div class="tooltip-content"><p>No information available.</p></div>';
    }

    // Helper function to escape HTML characters for safe display.
    // This is implemented to prevent Cross-Site Scripting (XSS) vulnerabilities
    // by converting characters like '<' to '&lt;' before inserting into HTML.
    function escapeHTML(str) {
        const div = document.createElement('div');
        div.appendChild(document.createTextNode(str)); // Safely creates a text node
        return div.innerHTML; // Returns the HTML-escaped string
    }

    // Construct the HTML string for the tooltip's content using template literals.
    // Ensure dynamic content (like name, email, phone, role) is escaped before insertion.
    // This protects against malicious data injected into the database.
    
    // Generates HTML for the email link if EMAIL_ADDR exists.
    // The email address itself is escaped for safety within the mailto: URL and displayed text.
    const emailHtml = person.EMAIL_ADDR ? `<p><span class="tooltip_label">Email:</span> <a href="mailto:${escapeHTML(person.EMAIL_ADDR)}">${escapeHTML(person.EMAIL_ADDR)}</a></p>` : '';
    
    // Generates HTML for the phone link if WORKPH1 exists.
    // The phone number itself is escaped for safety within the tel: URL and displayed text.
    const phoneHtml = person.WORKPH1 ? `<p><span class="tooltip_label">Phone:</span> <a href="tel:${escapeHTML(person.WORKPH1)}">${escapeHTML(person.WORKPH1)}</a></p>` : '';

    // Returns the complete HTML structure for the tooltip's content.
    return `
        <div class="tooltip-content">
            <p class="tooltip_heading">Personnel Information</p>
            <p><span class="tooltip_label">Name:</span> ${escapeHTML(person.FIRSTNAME)} ${escapeHTML(person.LASTNAME)}</p>
            <p><span class="tooltip_label">Role:</span> ${escapeHTML(person.FULL_POSITION_NAME)}</p>
            ${emailHtml}
            ${phoneHtml}
        </div>
    `;

}
