document.addEventListener("DOMContentLoaded", function () {
    const floater = document.querySelector(".admonition.is-category-tip-floater");
    const docsMain = document.querySelector("docs-main");
     
    // Check session storage to see if the popup should be hidden
    if (sessionStorage.getItem("floaterDismissed") === "true") {
        // Do not show the popup
        if (floater) floater.style.display = "none";
        return;
    } 

    if (floater) {
        // Move floater to the body to make it global
        document.body.appendChild(floater);

        // Apply base styles from `.admonition.is-tip`
        applyBaseStyles(floater, ".admonition.is-tip");

        // Add floating-specific styles
        Object.assign(floater.style, {
            position: 'fixed',
            top: '10px',
            right: '10px',
            zIndex: '1000',
            borderRadius: '10px',
            boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)',
        });

        createFloaterLink(floater);

        // Create and append the close button
        createCloseButton(floater);

        // Automatically hide the floater if it overlaps with the main body
        // observeOverlap(floater);
    }
});

/**
 * Apply base styles from a given CSS selector to a target element.
 * Fallback styles are applied if the selector does not exist.
 */
function applyBaseStyles(target, selector) {
    const baseStyles = getCSSRule(selector);

    if (baseStyles) {
        for (const key of baseStyles) {
            target.style[key] = baseStyles.getPropertyValue(key);
        }
    } else {
        Object.assign(target.style, {
            backgroundColor: getEffectiveBackgroundColor(),
            color: getEffectiveTextColor(),
            fontFamily: 'Arial, sans-serif',
            fontSize: '14px',
            padding: '15px',
            border: '1px solid #ddd',
        });
    }
}

/**
 * Get the CSSStyleDeclaration for a given selector.
 */
function getCSSRule(selector) {
    for (const sheet of document.styleSheets) {
        try {
            for (const rule of sheet.cssRules) {
                if (rule.selectorText === selector) {
                    return rule.style;
                }
            }
        } catch (e) {
            console.warn("Could not access stylesheet:", sheet.href);
        }
    }
    return null;
}


/**
 * Wraps the floater's content in a link to JuliaHub, excluding the close button.
 */
function createFloaterLink(floater) {
    // Create the clickable link wrapper
    const link = document.createElement("a");
    link.href = "https://juliahub.com";
    link.target = "_blank"; // Open in new tab
    link.style.textDecoration = "none"; // Remove underlines
    link.style.color = "inherit"; // Inherit text color
    link.style.display = "block"; // Make entire floater clickable

    // Move all floater children into the link except the close button
    while (floater.firstChild) {
        if (!floater.firstChild.classList?.contains("close-btn")) {
            link.appendChild(floater.firstChild);
        } else {
            break; // Stop before moving the close button
        }
    }

    // Insert the link back inside the floater
    floater.prepend(link);
}

function createCloseButton(floater) {
    const closeBtn = document.createElement("button");
    closeBtn.innerText = "×";

    Object.assign(closeBtn.style, {
        position: 'absolute',         // Overlay on the top-right corner
        top: '5px',                  // Position near the top of the floater
        right: '5px',                // Position near the right of the floater
        width: '20px',               // Smaller circular button
        height: '20px',              // Matches width for a perfect circle
        display: 'flex',             // Flexbox for centering the text
        alignItems: 'center',        // Vertically center the × symbol
        justifyContent: 'center',    // Horizontally center the × symbol
        fontSize: '14px',            // Adjust font size for better balance
        fontWeight: 'bold',          
        lineHeight: '1',             // Remove extra line spacing
        border: 'none',
        borderRadius: '50%',         // Circular button
        padding: '0',                // Remove default button padding
        cursor: 'pointer',
        transform: 'translate(50%, -50%)', // Ensure precise centering of the button
        backgroundColor: adjustBrightness(getEffectiveBackgroundColor(), -30), // Matches theme
        color: adjustBrightness(getEffectiveTextColor(), 150),                 // Matches theme
        boxShadow: '0 2px 4px rgba(0, 0, 0, 0.2)', // Subtle shadow for depth
        transition: 'background-color 0.2s ease',
        zIndex: '1001',              // Ensure it stays above the floater content
    });

    // Hover effects for the button
    closeBtn.addEventListener("mouseenter", () => {
        closeBtn.style.backgroundColor = adjustBrightness(getEffectiveBackgroundColor(), -50);
    });
    closeBtn.addEventListener("mouseleave", () => {
        closeBtn.style.backgroundColor = adjustBrightness(getEffectiveBackgroundColor(), -30);
    });

    // Close functionality
    closeBtn.addEventListener("click", () => {
        floater.style.display = "none";
        sessionStorage.setItem("floaterDismissed", "true"); // Track dismissal for the session
    });

    // Append the button to the floater
    floater.appendChild(closeBtn);
}

/**
 * Get the effective background color by checking multiple levels of the DOM.
 */
function getEffectiveBackgroundColor() {
    let bgColor = getComputedStyle(document.body).backgroundColor;

    if (!bgColor || bgColor === "rgba(0, 0, 0, 0)" || bgColor === "transparent") {
        bgColor = getComputedStyle(document.documentElement).backgroundColor;
    }

    return bgColor === "rgba(0, 0, 0, 0)" || bgColor === "transparent" ? "#fff" : bgColor;
}

/**
 * Get the effective text color by checking multiple levels of the DOM.
 */
function getEffectiveTextColor() {
    let textColor = getComputedStyle(document.body).color;

    if (!textColor) {
        textColor = getComputedStyle(document.documentElement).color;
    }

    return textColor || "#000";
}

/**
 * Adjust the brightness of a given color (hex or rgb).
 */
function adjustBrightness(color, amount) {
    let r, g, b;

    if (color.startsWith('rgb')) {
        [r, g, b] = color.match(/\d+/g).map(Number);
    } else if (color.startsWith('#')) {
        const bigint = parseInt(color.slice(1), 16);
        r = (bigint >> 16) & 255;
        g = (bigint >> 8) & 255;
        b = bigint & 255;
    } else {
        return color;
    }

    r = Math.min(255, Math.max(0, r + amount));
    g = Math.min(255, Math.max(0, g + amount));
    b = Math.min(255, Math.max(0, b + amount));

    return `rgb(${r}, ${g}, ${b})`;
}


/**
 * Observes the floater and hides it if it overlaps with the main body.
 */
function observeOverlap(floater) {
    const mainBody = document.querySelector("main") || document.body; // Replace with your main content selector
    if (!mainBody) return;

    const observer = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                const intersectionRatio = entry.intersectionRatio;
                const threshold = 0.1; // Set your desired threshold (e.g., 10%)

                if (intersectionRatio > threshold) {
                    // Hide floater if overlapping beyond the threshold
                    floater.style.display = "none";
                } else {
                    // Restore floater if overlap is below the threshold
                    floater.style.display = "block";
                }
            });
        },
        {
            root: null, // Observe the viewport
            threshold: [0, 0.1, 1], // Trigger at 0%, 10%, and 100% intersection
        }
    );

    observer.observe(floater);
}