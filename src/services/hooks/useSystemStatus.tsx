import { useState, useEffect } from "react";
import { Status } from "../../utils/constants";
import ServiceStatus from "../types/ServiceStatus";
import SystemStatus from "../types/SystemStatus";

function useSystemStatus() {
    const [systemStatus, setSystemStatus] = useState<SystemStatus>();
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState();

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            try {
                const response = await fetch("./urls.cfg");
                const configText = await response.text();
                const configLines = configText.split("\n");
                const services: ServiceStatus[] = [];
                for (let ii = 0; ii < configLines.length; ii++) {
                    const configLine = configLines[ii];
                    const [key, url] = configLine.split("=");
                    if (!key || !url) {
                        continue;
                    }
                    const status = await logs(key);

                    services.push(status);
                }
                
                if (services.every((item) => item.status === "success")) {
                    setSystemStatus({
                        title: "All System Operational",
                        status: Status.OPERATIONAL,
                        datetime: services[0].date
                    });
                } else if (services.every((item) => item.status === "failed")) {
                    setSystemStatus({
                        title: "Outage",
                        status: Status.OUTAGE,
                        datetime: services[0].date
                     });
                } else if (services.every((item) => item.status === "")) {
                    setSystemStatus({
                        title: "Unknown",
                        status: Status.UNKNOWN,
                        datetime: services[0].date
                    });
                } else {
                    setSystemStatus({
                        title: "Partial Outage",
                        status: Status.PARTIAL_OUTAGE,
                        datetime: services[0].date
                    });
                }
            } catch (e: any) {
                setError(e);
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, []);

    return {systemStatus, isLoading, error};
}

async function logs(key: string): Promise<ServiceStatus> {
    const response = await fetch(`https://raw.githubusercontent.com/Cogoport/status.cogoport/cogo-status/public/status/${key}_report.log`,
        {
            "method": "GET",
            // headers: {
            //     "Accept": "application/vnd.github.raw",
            //     "Access-Control-Allow-Origin": "*",
            //     "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            //     "Access-Control-Allow-Headers": "X-Requested-With, Content-Type, Authorization",
            //     'X-GitHub-Api-Version': '2022-11-28',
            //     "Authorization": `token ${process.env.NEXT_PUBLIC_GITHUB_TOKEN}`
            // }
        });
    const text = await response.text();
    const lines = text.split("\n");
    try {
        const line = lines[lines.length - 2];
        const [created_at, status, _] = line.split(", ");
        return {
            name: key,
            status: status,
            date: created_at,
        };
    } catch (e) {
        return {
            name: key,
            status: "unknown",
            date: undefined,
        };
    }
}

export default useSystemStatus;
