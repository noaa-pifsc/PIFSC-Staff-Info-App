// Initialize Tippy.js for all elements with the 'person-tooltip-trigger' class
tippy('.person-tooltip-trigger', {
	interactive: true,
	allowHTML: true,
	placement: 'auto', // Or 'auto', 'bottom', etc.
	theme: 'custom-tooltip',
	// This function dynamically gets the content from the hidden div
	content(reference) {
		const id = reference.getAttribute('data-tooltip-id');
		const contentElement = document.getElementById(id);
		return contentElement ? contentElement.innerHTML : 'No content found';
	},
	delay: [100, 0],
	// Optional: A custom duration for showing/hiding
	duration: 200,
});
