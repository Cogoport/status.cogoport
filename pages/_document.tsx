import { Html, Head, Main, NextScript } from 'next/document'
import Script from 'next/script'

export default function Document() {
    return (
        <Html className="light scroll-smooth">
            <Head />
            <body className="dark:bg-gray-800">
                <Main />
                <NextScript />
                <Script src="https://cdn.tailwindcss.com"/>
            </body>
        </Html>
    )
}