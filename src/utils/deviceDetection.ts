// Utilitaires de détection d'appareil
export interface DeviceInfo {
  type: 'mobile' | 'tablet' | 'desktop';
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
  screenWidth: number;
  userAgent: string;
}

export function detectDevice(): DeviceInfo {
  if (typeof window === 'undefined') {
    // Côté serveur, retourner desktop par défaut
    return {
      type: 'desktop',
      isMobile: false,
      isTablet: false,
      isDesktop: true,
      screenWidth: 1920,
      userAgent: ''
    };
  }

  const userAgent = navigator.userAgent.toLowerCase();
  const screenWidth = window.innerWidth;
  
  // Détection basée sur User-Agent
  const isMobileUA = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent);
  const isTabletUA = /ipad|android(?!.*mobile)|tablet/i.test(userAgent);
  
  // Détection basée sur la taille d'écran
  const isMobileScreen = screenWidth < 768;
  const isTabletScreen = screenWidth >= 768 && screenWidth < 1024;
  const isDesktopScreen = screenWidth >= 1024;
  
  // Combinaison des deux approches
  let deviceType: 'mobile' | 'tablet' | 'desktop';
  
  if (isMobileScreen || (isMobileUA && !isTabletUA)) {
    deviceType = 'mobile';
  } else if (isTabletScreen || isTabletUA) {
    deviceType = 'tablet';
  } else {
    deviceType = 'desktop';
  }
  
  return {
    type: deviceType,
    isMobile: deviceType === 'mobile',
    isTablet: deviceType === 'tablet',
    isDesktop: deviceType === 'desktop',
    screenWidth,
    userAgent
  };
}

export function getDeviceSpecificClasses(device: DeviceInfo): string {
  const baseClasses = [];
  
  if (device.isMobile) {
    baseClasses.push('device-mobile');
  } else if (device.isTablet) {
    baseClasses.push('device-tablet');
  } else {
    baseClasses.push('device-desktop');
  }
  
  return baseClasses.join(' ');
}