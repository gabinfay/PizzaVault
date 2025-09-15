'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import PizzaMeter from '@/components/PizzaMeter';
import DepositForm from '@/components/DepositForm';
import AllocationChart from '@/components/AllocationChart';
import OracleControls from '@/components/OracleControls';
import WithdrawPanel from '@/components/WithdrawPanel';
import StakingDashboard from '@/components/StakingDashboard';
import Header from '@/components/Header';
import { Toaster } from '@/components/ui/sonner';

export default function Home() {
  const [defconLevel, setDefconLevel] = useState(2);
  const [ethBalance, setEthBalance] = useState(0);
  const [pzzaBalance, setPzzaBalance] = useState(100);
  const [isConnected, setIsConnected] = useState(false);
  const [eventLog, setEventLog] = useState<Array<{level: number, timestamp: Date, allocation: string}>>([]);

  useEffect(() => {
    setEventLog([
      { level: 2, timestamp: new Date(), allocation: 'ETH High Risk' }
    ]);
  }, []);

  const allocation = defconLevel <= 2 ? 'ETH' : 'USDC';

  const handleDefconChange = (newLevel: number) => {
    setDefconLevel(newLevel);
    const newAllocation = newLevel <= 2 ? 'ETH High Risk' : 'USDC Low Risk';
    
    setEventLog(prev => [...prev, {
      level: newLevel,
      timestamp: new Date(),
      allocation: newAllocation
    }]);
  };

  const handleDeposit = (amount: number) => {
    setEthBalance(prev => prev + amount);
  };

  const handleWithdraw = () => {
    setEthBalance(0);
  };

  const handleStake = (amount: number) => {
    if (pzzaBalance >= amount) {
      setPzzaBalance(prev => prev - amount + 10); // Stake + reward
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-red-50">
      <Header isConnected={isConnected} onConnect={() => setIsConnected(true)} />
      
      <main className="container mx-auto px-4 py-8 space-y-8">
        {/* Hero Section */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <div className="flex items-center justify-center gap-3 mb-4">
            <span className="text-6xl">🍕</span>
            <span className="text-6xl">⚡</span>
          </div>
          <h1 className="text-4xl md:text-6xl font-bold bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-transparent mb-4">
            Yielderita
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            When pizza is calm, we risk-on ETH. When pizza spikes, we hide in USDC.
          </p>
        </motion.div>

        {/* Main Dashboard Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column */}
          <div className="space-y-8">
            <PizzaMeter level={defconLevel} />
            <DepositForm onDeposit={handleDeposit} isConnected={isConnected} />
            <WithdrawPanel onWithdraw={handleWithdraw} balance={ethBalance} />
          </div>

          {/* Center Column */}
          <div className="space-y-8">
            <AllocationChart allocation={allocation} ethBalance={ethBalance} />
            <StakingDashboard 
              balance={pzzaBalance} 
              onStake={handleStake}
              isConnected={isConnected}
            />
          </div>

          {/* Right Column */}
          <div className="space-y-8">
            <OracleControls 
              onDefconChange={handleDefconChange} 
              currentLevel={defconLevel}
              eventLog={eventLog}
            />
          </div>
        </div>

        {/* Footer */}
        <motion.footer 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-center text-gray-500 py-8"
        >
          <p>Yielderita Demo • Built with &lt;3 for PizzaDAO at ETHTokyo 2025</p>
        </motion.footer>
      </main>

      <Toaster />
    </div>
  );
}
