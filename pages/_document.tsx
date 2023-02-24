import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
    return (
        <Html className="light scroll-smooth">
            <Head />
            <body className="dark:bg-gray-800">
                <Main />
                <NextScript />
            </body>
        </Html>
    )
}