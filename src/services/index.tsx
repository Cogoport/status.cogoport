import useServices from './hooks/useServices';
import type { NextPage } from 'next'
import Service from './types/Service';
import ServiceItem from './components/service';
import IncidentsSection from '../incidents';
import useSystemStatus from './hooks/useSystemStatus';
import { Status } from '../utils/constants';
import { useEffect, useRef, useState } from 'react';


const ServicesSection: NextPage = () => {
    const [data, isServicesLoading] = useServices();
    const { systemStatus, isLoading } = useSystemStatus();
    const [activeSectionIndex, setActiveSectionIndex] = useState(0);

    const sectionRefs = useRef<any[]>([]);


    useEffect(() => {
        const handleScroll = () => {
            const currentPosition = window.scrollY;
            let currentSectionIndex = 0;

            sectionRefs.current.forEach((sectionRef, index) => {
                if (sectionRef) {
                    const sectionTop = sectionRef.offsetTop + 60;
                    if (currentPosition >= sectionTop) {
                        currentSectionIndex = index;
                    }
                }
            });

            setActiveSectionIndex(currentSectionIndex);
        };

        window.addEventListener("scroll", handleScroll);
        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    const scrollToSection = (index: any) => {
        const sectionTop = sectionRefs.current[index].offsetTop + 60;
        window.scrollTo({ top: sectionTop, behavior: "smooth" });
    };

    const Icon = () => {
        if (systemStatus?.status === Status.OPERATIONAL) {
            return <svg className="h-6 w-6 flex-none fill-sky-100 stroke-green-500 stroke-2">
                <circle cx="12" cy="12" r="11" />
                <path d="m8 13 2.165 2.165a1 1 0 0 0 1.521-.126L16 9" fill="none" />
            </svg>
        } else if (systemStatus?.status === Status.PARTIAL_OUTAGE) {
            return <svg className="h-8 w-8 flex-none" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" fill="orange">
                <path d="M256 48C141.31 48 48 141.31 48 256s93.31 208 208 208 208-93.31 208-208S370.69 48 256 48zm0 319.91a20 20 0 1 1 20-20 20 20 0 0 1-20 20zm21.72-201.15-5.74 122a16 16 0 0 1-32 0l-5.74-121.94v-.05a21.74 21.74 0 1 1 43.44 0z"></path>
            </svg>
        } else if (systemStatus?.status === Status.OUTAGE) {
            return <svg className="h-8 w-8 flex-none" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" fill="red">
                <path d="M256 48C141.31 48 48 141.31 48 256s93.31 208 208 208 208-93.31 208-208S370.69 48 256 48zm0 319.91a20 20 0 1 1 20-20 20 20 0 0 1-20 20zm21.72-201.15-5.74 122a16 16 0 0 1-32 0l-5.74-121.94v-.05a21.74 21.74 0 1 1 43.44 0z"></path>
            </svg>
        } else {
            return <svg className="h-6 w-6 flex-none fill-sky-100 stroke-green-500 stroke-2">
                <circle cx="12" cy="12" r="11" />
                <path d="m8 13 2.165 2.165a1 1 0 0 0 1.521-.126L16 9" fill="none" />
            </svg>
        }
    }

    return (
        <div className='mt-10 mx-5 md:mx-0'>
            <div className="mx-px md:ml-80 md:mr-80 bg-white dark:bg-slate-800 rounded-xl card">
                <div className="w-full flex justify-between pt-2 pl-6 pr-6 pb-2">
                    <div className='flex items-center sm:text-xl text-xs font-semibold leading-7'>
                        <Icon />
                        <p className="ml-3 text-gray-900">{systemStatus?.title}</p>
                    </div>
                    <div>
                        <p className="text-xs text-gray-400">Last updated</p>
                        <p className="text-xs text-gray-400 text-end ">{systemStatus?.datetime}</p>
                    </div>
                </div>
            </div>
            <div className='flex flex-col mt-5 md:mx-52'>
                <h1 className="text-4xl font-normal leading-normal mb-5">Cogoport Health</h1>
                <div className='flex'>
                    <aside className='hidden md:flex flex-auto w-1/4 justify-start pt-5 h-screen sticky top-0'>
                        <ul className="sticky top-0">
                            <li className={`cursor-pointer ${(activeSectionIndex === 0 || activeSectionIndex === 1 || activeSectionIndex === 2) ? "text-black font-medium" : "text-slate-700"}`} onClick={() => scrollToSection(0)}>Frontend</li>
                            <ul className={`ml-2 ${(activeSectionIndex === 0 || activeSectionIndex === 1 || activeSectionIndex === 2) ? "block" : "hidden"}`}>
                                <li className={`cursor-pointer ${activeSectionIndex === 0 ? "text-black font-medium" : "text-slate-700"}`}
                                    onClick={() => scrollToSection(0)}>
                                    Admin
                                </li>
                                <li className={`cursor-pointer ${activeSectionIndex === 1 ? "text-black font-medium" : "text-slate-700"}`}
                                    onClick={() => scrollToSection(1)}>
                                    Partner
                                </li>
                                <li className={`cursor-pointer ${activeSectionIndex === 2 ? "text-black font-medium" : "text-slate-700"}`}
                                    onClick={() => scrollToSection(2)}>
                                    App
                                </li>
                            </ul>
                            <li className={`cursor-pointer mb-2 ${activeSectionIndex === 3 ? "text-black font-medium" : "text-slate-700"}`}
                                onClick={() => scrollToSection(3)}>
                                Backend
                            </li>
                        </ul>
                    </aside>
                    <main className='flex-auto w-3/4 pt-5 pb-96' >
                        <div className="card-body">
                            {
                                isServicesLoading ? (
                                    <p>Loading...</p>
                                ) : (
                                    <ul>
                                        {
                                            (data as Service[]).map((service, i) => (
                                                <li className='shadow-md bg-white p-5 mb-5 rounded-lg' key={service.id} ref={(ref) => (sectionRefs.current[i] = ref)}>
                                                    <ServiceItem item={service} />
                                                    <p className="sm:text-lg text-base font-semibold leading-7 text-gray-900">Recent incident</p>
                                                    <IncidentsSection />
                                                </li>
                                            ))
                                        }
                                    </ul>
                                )
                            }
                        </div>
                    </main>
                </div>
            </div>
        </div >
    )
}

export default ServicesSection;
